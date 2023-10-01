package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"time"

	projects_api "github.com/JohanHellmark/HomeLab/services/web-server/api/projects"
	otel "github.com/JohanHellmark/HomeLab/services/web-server/internal/otel"
	server "github.com/JohanHellmark/HomeLab/services/web-server/internal/projects"
	"github.com/caarlos0/env/v9"
	oapiMW "github.com/deepmap/oapi-codegen/pkg/chi-middleware"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/chi/v5"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	semconv "go.opentelemetry.io/otel/semconv/v1.17.0"
	"go.opentelemetry.io/otel/trace"
)

type config struct {
	Home         string         `env:"HOME"`
	Port         int            `env:"PORT" envDefault:"3000"`
	Password     string         `env:"PASSWORD,unset"`
	IsProduction bool           `env:"PRODUCTION"`
	Hosts        []string       `env:"HOSTS" envSeparator:":"`
	TempFolder   string         `env:"TEMP_FOLDER,expand" envDefault:"${HOME}/tmp"`
	StringInts   map[string]int `env:"MAP_STRING_INT"`
}

func main() {
	// Handle SIGINT (CTRL+C) gracefully.
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	// Set up OpenTelemetry.
	serviceName := "project"
	serviceVersion := "0.1.0"
	otelShutdown, err := otel.SetupOTelSDK(ctx, serviceName, serviceVersion)
	if err != nil {
		return
	}
	// Handle shutdown properly so nothing leaks.
	defer func() {
		err = errors.Join(err, otelShutdown(context.Background()))
	}()

	cfg := config{}
	if err := env.Parse(&cfg); err != nil {
		fmt.Printf("%+v\n", err)
	}
	port := flag.String("port", "8080", "Port for test HTTP server")
	flag.Parse()

	swagger, err := projects_api.GetSwagger()

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading swagger spec\n: %s", err)
		os.Exit(1)
	}

	// Clear out the servers array in the swagger spec, that skips validating
	// that server names match. We don't know how this thing will be run.
	swagger.Servers = nil

	// This is how you set up a basic chi router
	r := chi.NewRouter()

	// Use our validation middleware to check all requests against the
	// OpenAPI schema.

	// A good base middleware stack
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))
	r.Use(oapiMW.OapiRequestValidator(swagger))
	r.Use(func(next http.Handler) http.Handler {
		return otelhttp.NewHandler(
			http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				next.ServeHTTP(w, r)

				// Enriches the span with information about the context
				routePattern := chi.RouteContext(r.Context()).RoutePattern()
				span := trace.SpanFromContext(r.Context())
				span.SetName(routePattern)
				span.SetAttributes(semconv.HTTPTarget(r.URL.String()), semconv.HTTPRoute(routePattern))

				labeler, ok := otelhttp.LabelerFromContext(r.Context())
				if ok {
					labeler.Add(semconv.HTTPRoute(routePattern))
				}
			}),
			"",
		)
	})

	p := make(map[int64]projects_api.Project)
	p[1] = projects_api.Project{
		Name: "First project",
		Id:   1,
	}
	p[2] = projects_api.Project{
		Name: "Second project",
		Id:   2,
	}
	// We now register our handler for the interface
	// Create an instance of our handler which satisfies the generated interface
	projectHandler := server.ProjectHandler{
		Projects: p,
		NextId:   100,
	}
	strictProjectHandler := projects_api.NewStrictHandler(projectHandler, nil)
	projects_api.HandlerFromMux(strictProjectHandler, r)

	fmt.Println("Starting Server...")
	s := &http.Server{
		Handler: r,
		Addr:    net.JoinHostPort("0.0.0.0", *port),
	}

	// And we serve HTTP until the world ends.
	srvErr := make(chan error, 1)
	go func() {
		srvErr <- s.ListenAndServe()
	}()

	// Wait for interruption.
	select {
	case err = <-srvErr:
		// Error when starting HTTP server.
		return
	case <-ctx.Done():
		// Wait for first CTRL+C.
		// Stop receiving signal notifications as soon as possible.
		stop()
	}

	return
}
