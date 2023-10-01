package server

import (
	"context"
	"math/rand"

	api "github.com/JohanHellmark/HomeLab/services/web-server/api/projects"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
)

type ProjectHandler struct {
	Projects map[int64]api.Project
	NextId   int64
}

var _ api.StrictServerInterface = (*ProjectHandler)(nil)
var (
	tracer = otel.Tracer("random")
)

func (p ProjectHandler) ListProjects(ctx context.Context, request api.ListProjectsRequestObject) (api.ListProjectsResponseObject, error) {
	ctx, span := tracer.Start(ctx, "list")
	defer span.End()
	roll := 1 + rand.Intn(6)
	rollValueAttr := attribute.Int("value", roll)
	span.SetAttributes(rollValueAttr)

	var result []api.Project
	for _, Project := range p.Projects {
		result = append(result, Project)
		if request.Params.Limit != nil {
			l := int(*request.Params.Limit)
			if len(result) >= l {
				// We're at the limit
				break
			}
		}
	}
	return api.ListProjects200JSONResponse(result), nil
}
