package framework

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

var _ resource.ResourceWithMoveState = &resourceWithMoveState{}

func NewResourceWithMoveStateWrapper(r resource.Resource) resource.Resource {
	return &resourceWithMoveState{r: r}
}

type resourceWithMoveState struct {
	r resource.Resource
}

func (r *resourceWithMoveState) Metadata(ctx context.Context, request resource.MetadataRequest, response *resource.MetadataResponse) {
	r.Metadata(ctx, request, response)
}

func (r *resourceWithMoveState) Schema(ctx context.Context, request resource.SchemaRequest, response *resource.SchemaResponse) {
	r.Schema(ctx, request, response)
}

func (r *resourceWithMoveState) Create(ctx context.Context, request resource.CreateRequest, response *resource.CreateResponse) {
	r.Create(ctx, request, response)
}

func (r *resourceWithMoveState) Read(ctx context.Context, request resource.ReadRequest, response *resource.ReadResponse) {
	r.Read(ctx, request, response)
}

func (r *resourceWithMoveState) Update(ctx context.Context, request resource.UpdateRequest, response *resource.UpdateResponse) {
	r.Update(ctx, request, response)
}

func (r *resourceWithMoveState) Delete(ctx context.Context, request resource.DeleteRequest, response *resource.DeleteResponse) {
	r.Delete(ctx, request, response)
}

func (r *resourceWithMoveState) MoveState(ctx context.Context) []resource.StateMover {
	return []resource.StateMover{
		{
			SourceSchema: nil,
			StateMover: func(ctx context.Context, request resource.MoveStateRequest, response *resource.MoveStateResponse) {
				if request.SourceTypeName != "azapi_resource" {
					response.Diagnostics.AddError("Invalid source type", "The source type is not azapi_resource")
					return
				}

				if request.SourceState == nil {
					response.Diagnostics.AddError("Invalid source state", "The source state is nil")
					return
				}

				id := ""
				if response.Diagnostics.Append(request.SourceState.GetAttribute(ctx, path.Root("id"), &id)...); response.Diagnostics.HasError() {
					return
				}

				state := struct {
					ID types.String `tfsdk:"id"`
				}{}
				state.ID = types.StringValue(id)

				response.Diagnostics.Append(response.TargetState.Set(ctx, state)...)
			},
		},
	}
}
