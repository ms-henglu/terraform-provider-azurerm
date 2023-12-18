package containers

// NOTE: this file is generated - manual changes will be overwritten.
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See NOTICE.txt in the project root for license information.
import (
	"context"
	"fmt"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/pointer"
	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/commonids"
	"github.com/hashicorp/go-azure-sdk/resource-manager/containerservice/2023-10-15/fleetupdatestrategies"
	"github.com/hashicorp/terraform-provider-azurerm/internal/sdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
)

var _ sdk.Resource = KubernetesFleetUpdateStrategyResource{}
var _ sdk.ResourceWithUpdate = KubernetesFleetUpdateStrategyResource{}

type KubernetesFleetUpdateStrategyResource struct{}

func (r KubernetesFleetUpdateStrategyResource) ModelObject() interface{} {
	return &KubernetesFleetUpdateStrategyResourceSchema{}
}

type KubernetesFleetUpdateStrategyResourceSchema struct {
	FleetId  string                                                         `tfschema:"fleet_id"`
	Name     string                                                         `tfschema:"name"`
	Strategy []KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema `tfschema:"strategy"`
}

func (r KubernetesFleetUpdateStrategyResource) IDValidationFunc() pluginsdk.SchemaValidateFunc {
	return fleetupdatestrategies.ValidateUpdateStrategyID
}
func (r KubernetesFleetUpdateStrategyResource) ResourceType() string {
	return "azurerm_kubernetes_fleet_update_strategy"
}
func (r KubernetesFleetUpdateStrategyResource) Arguments() map[string]*pluginsdk.Schema {
	return map[string]*pluginsdk.Schema{
		"fleet_id": {
			ForceNew: true,
			Required: true,
			Type:     pluginsdk.TypeString,
		},
		"name": {
			ForceNew: true,
			Required: true,
			Type:     pluginsdk.TypeString,
		},
		"strategy": {
			Elem: &pluginsdk.Resource{
				Schema: map[string]*pluginsdk.Schema{
					"stage": {
						Elem: &pluginsdk.Resource{
							Schema: map[string]*pluginsdk.Schema{
								"group": {
									Elem: &pluginsdk.Resource{
										Schema: map[string]*pluginsdk.Schema{
											"name": {
												Required: true,
												Type:     pluginsdk.TypeString,
											},
										},
									},
									Required: true,
									Type:     pluginsdk.TypeList,
								},
								"name": {
									Required: true,
									Type:     pluginsdk.TypeString,
								},
								"after_stage_wait_in_seconds": {
									Optional: true,
									Type:     pluginsdk.TypeInt,
								},
							},
						},
						Required: true,
						Type:     pluginsdk.TypeList,
					},
				},
			},
			MaxItems: 1,
			Required: true,
			Type:     pluginsdk.TypeList,
		},
	}
}
func (r KubernetesFleetUpdateStrategyResource) Attributes() map[string]*pluginsdk.Schema {
	return map[string]*pluginsdk.Schema{}
}
func (r KubernetesFleetUpdateStrategyResource) Create() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.ContainerService.V20231015.FleetUpdateStrategies

			var config KubernetesFleetUpdateStrategyResourceSchema
			if err := metadata.Decode(&config); err != nil {
				return fmt.Errorf("decoding: %+v", err)
			}

			subscriptionId := metadata.Client.Account.SubscriptionId

			fleetId, err := commonids.ParseFleetID(config.FleetId)
			if err != nil {
				return err
			}

			id := fleetupdatestrategies.NewUpdateStrategyID(subscriptionId, fleetId.ResourceGroupName, fleetId.FleetName, config.Name)

			existing, err := client.Get(ctx, id)
			if err != nil {
				if !response.WasNotFound(existing.HttpResponse) {
					return fmt.Errorf("checking for the presence of an existing %s: %+v", id, err)
				}
			}
			if !response.WasNotFound(existing.HttpResponse) {
				return metadata.ResourceRequiresImport(r.ResourceType(), id)
			}

			var payload fleetupdatestrategies.FleetUpdateStrategy
			if err := r.mapKubernetesFleetUpdateStrategyResourceSchemaToFleetUpdateStrategy(config, &payload); err != nil {
				return fmt.Errorf("mapping schema model to sdk model: %+v", err)
			}

			if err := client.CreateOrUpdateThenPoll(ctx, id, payload, fleetupdatestrategies.DefaultCreateOrUpdateOperationOptions()); err != nil {
				return fmt.Errorf("creating %s: %+v", id, err)
			}

			metadata.SetID(id)
			return nil
		},
	}
}
func (r KubernetesFleetUpdateStrategyResource) Read() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 5 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.ContainerService.V20231015.FleetUpdateStrategies
			schema := KubernetesFleetUpdateStrategyResourceSchema{}

			id, err := fleetupdatestrategies.ParseUpdateStrategyID(metadata.ResourceData.Id())
			if err != nil {
				return err
			}

			fleetId := commonids.NewFleetID(id.SubscriptionId, id.ResourceGroupName, id.FleetName)

			resp, err := client.Get(ctx, *id)
			if err != nil {
				if response.WasNotFound(resp.HttpResponse) {
					return metadata.MarkAsGone(*id)
				}
				return fmt.Errorf("retrieving %s: %+v", *id, err)
			}

			if model := resp.Model; model != nil {
				schema.FleetId = fleetId.ID()
				schema.Name = id.UpdateStrategyName
				if err := r.mapFleetUpdateStrategyToKubernetesFleetUpdateStrategyResourceSchema(*model, &schema); err != nil {
					return fmt.Errorf("flattening model: %+v", err)
				}
			}

			return metadata.Encode(&schema)
		},
	}
}
func (r KubernetesFleetUpdateStrategyResource) Delete() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.ContainerService.V20231015.FleetUpdateStrategies

			id, err := fleetupdatestrategies.ParseUpdateStrategyID(metadata.ResourceData.Id())
			if err != nil {
				return err
			}

			if err := client.DeleteThenPoll(ctx, *id, fleetupdatestrategies.DefaultDeleteOperationOptions()); err != nil {
				return fmt.Errorf("deleting %s: %+v", *id, err)
			}

			return nil
		},
	}
}
func (r KubernetesFleetUpdateStrategyResource) Update() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.ContainerService.V20231015.FleetUpdateStrategies

			id, err := fleetupdatestrategies.ParseUpdateStrategyID(metadata.ResourceData.Id())
			if err != nil {
				return err
			}

			var config KubernetesFleetUpdateStrategyResourceSchema
			if err := metadata.Decode(&config); err != nil {
				return fmt.Errorf("decoding: %+v", err)
			}

			existing, err := client.Get(ctx, *id)
			if err != nil {
				return fmt.Errorf("retrieving existing %s: %+v", *id, err)
			}
			if existing.Model == nil {
				return fmt.Errorf("retrieving existing %s: properties was nil", *id)
			}
			payload := *existing.Model

			if err := r.mapKubernetesFleetUpdateStrategyResourceSchemaToFleetUpdateStrategy(config, &payload); err != nil {
				return fmt.Errorf("mapping schema model to sdk model: %+v", err)
			}

			if err := client.CreateOrUpdateThenPoll(ctx, *id, payload, fleetupdatestrategies.DefaultCreateOrUpdateOperationOptions()); err != nil {
				return fmt.Errorf("updating %s: %+v", *id, err)
			}

			return nil
		},
	}
}

type KubernetesFleetUpdateStrategyResourceUpdateGroupSchema struct {
	Name string `tfschema:"name"`
}

type KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema struct {
	Stage []KubernetesFleetUpdateStrategyResourceUpdateStageSchema `tfschema:"stage"`
}

type KubernetesFleetUpdateStrategyResourceUpdateStageSchema struct {
	AfterStageWaitInSeconds int64                                                    `tfschema:"after_stage_wait_in_seconds"`
	Group                   []KubernetesFleetUpdateStrategyResourceUpdateGroupSchema `tfschema:"group"`
	Name                    string                                                   `tfschema:"name"`
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceSchemaToFleetUpdateStrategyProperties(input KubernetesFleetUpdateStrategyResourceSchema, output *fleetupdatestrategies.FleetUpdateStrategyProperties) error {
	if len(input.Strategy) > 0 {
		if err := r.mapKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchemaToFleetUpdateStrategyProperties(input.Strategy[0], output); err != nil {
			return err
		}
	}
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapFleetUpdateStrategyPropertiesToKubernetesFleetUpdateStrategyResourceSchema(input fleetupdatestrategies.FleetUpdateStrategyProperties, output *KubernetesFleetUpdateStrategyResourceSchema) error {
	tmpStrategy := &KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema{}
	if err := r.mapFleetUpdateStrategyPropertiesToKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema(input, tmpStrategy); err != nil {
		return err
	} else {
		output.Strategy = make([]KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema, 0)
		output.Strategy = append(output.Strategy, *tmpStrategy)
	}
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceUpdateGroupSchemaToUpdateGroup(input KubernetesFleetUpdateStrategyResourceUpdateGroupSchema, output *fleetupdatestrategies.UpdateGroup) error {
	output.Name = input.Name
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapUpdateGroupToKubernetesFleetUpdateStrategyResourceUpdateGroupSchema(input fleetupdatestrategies.UpdateGroup, output *KubernetesFleetUpdateStrategyResourceUpdateGroupSchema) error {
	output.Name = input.Name
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchemaToUpdateRunStrategy(input KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema, output *fleetupdatestrategies.UpdateRunStrategy) error {

	stages := make([]fleetupdatestrategies.UpdateStage, 0)
	for i, v := range input.Stage {
		item := fleetupdatestrategies.UpdateStage{}
		if err := r.mapKubernetesFleetUpdateStrategyResourceUpdateStageSchemaToUpdateStage(v, &item); err != nil {
			return fmt.Errorf("mapping KubernetesFleetUpdateStrategyResourceUpdateStageSchema item %d to UpdateStage: %+v", i, err)
		}
		stages = append(stages, item)
	}
	output.Stages = stages

	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapUpdateRunStrategyToKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema(input fleetupdatestrategies.UpdateRunStrategy, output *KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema) error {

	stages := make([]KubernetesFleetUpdateStrategyResourceUpdateStageSchema, 0)
	for i, v := range input.Stages {
		item := KubernetesFleetUpdateStrategyResourceUpdateStageSchema{}
		if err := r.mapUpdateStageToKubernetesFleetUpdateStrategyResourceUpdateStageSchema(v, &item); err != nil {
			return fmt.Errorf("mapping KubernetesFleetUpdateStrategyResourceUpdateStageSchema item %d to UpdateStage: %+v", i, err)
		}
		stages = append(stages, item)
	}
	output.Stage = stages

	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceUpdateStageSchemaToUpdateStage(input KubernetesFleetUpdateStrategyResourceUpdateStageSchema, output *fleetupdatestrategies.UpdateStage) error {
	output.AfterStageWaitInSeconds = &input.AfterStageWaitInSeconds

	groups := make([]fleetupdatestrategies.UpdateGroup, 0)
	for i, v := range input.Group {
		item := fleetupdatestrategies.UpdateGroup{}
		if err := r.mapKubernetesFleetUpdateStrategyResourceUpdateGroupSchemaToUpdateGroup(v, &item); err != nil {
			return fmt.Errorf("mapping KubernetesFleetUpdateStrategyResourceUpdateGroupSchema item %d to UpdateGroup: %+v", i, err)
		}
		groups = append(groups, item)
	}
	output.Groups = groups

	output.Name = input.Name
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapUpdateStageToKubernetesFleetUpdateStrategyResourceUpdateStageSchema(input fleetupdatestrategies.UpdateStage, output *KubernetesFleetUpdateStrategyResourceUpdateStageSchema) error {
	output.AfterStageWaitInSeconds = pointer.From(input.AfterStageWaitInSeconds)

	groups := make([]KubernetesFleetUpdateStrategyResourceUpdateGroupSchema, 0)
	for i, v := range input.Groups {
		item := KubernetesFleetUpdateStrategyResourceUpdateGroupSchema{}
		if err := r.mapUpdateGroupToKubernetesFleetUpdateStrategyResourceUpdateGroupSchema(v, &item); err != nil {
			return fmt.Errorf("mapping KubernetesFleetUpdateStrategyResourceUpdateGroupSchema item %d to UpdateGroup: %+v", i, err)
		}
		groups = append(groups, item)
	}
	output.Group = groups

	output.Name = input.Name
	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceSchemaToFleetUpdateStrategy(input KubernetesFleetUpdateStrategyResourceSchema, output *fleetupdatestrategies.FleetUpdateStrategy) error {

	if output.Properties == nil {
		output.Properties = &fleetupdatestrategies.FleetUpdateStrategyProperties{}
	}
	if err := r.mapKubernetesFleetUpdateStrategyResourceSchemaToFleetUpdateStrategyProperties(input, output.Properties); err != nil {
		return fmt.Errorf("mapping Schema to SDK Field %q / Model %q: %+v", "FleetUpdateStrategyProperties", "Properties", err)
	}

	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapFleetUpdateStrategyToKubernetesFleetUpdateStrategyResourceSchema(input fleetupdatestrategies.FleetUpdateStrategy, output *KubernetesFleetUpdateStrategyResourceSchema) error {

	if input.Properties == nil {
		input.Properties = &fleetupdatestrategies.FleetUpdateStrategyProperties{}
	}
	if err := r.mapFleetUpdateStrategyPropertiesToKubernetesFleetUpdateStrategyResourceSchema(*input.Properties, output); err != nil {
		return fmt.Errorf("mapping SDK Field %q / Model %q to Schema: %+v", "FleetUpdateStrategyProperties", "Properties", err)
	}

	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchemaToFleetUpdateStrategyProperties(input KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema, output *fleetupdatestrategies.FleetUpdateStrategyProperties) error {

	if err := r.mapKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchemaToUpdateRunStrategy(input, &output.Strategy); err != nil {
		return fmt.Errorf("mapping Schema to SDK Field %q / Model %q: %+v", "UpdateRunStrategy", "Strategy", err)
	}

	return nil
}

func (r KubernetesFleetUpdateStrategyResource) mapFleetUpdateStrategyPropertiesToKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema(input fleetupdatestrategies.FleetUpdateStrategyProperties, output *KubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema) error {

	if err := r.mapUpdateRunStrategyToKubernetesFleetUpdateStrategyResourceUpdateRunStrategySchema(input.Strategy, output); err != nil {
		return fmt.Errorf("mapping SDK Field %q / Model %q to Schema: %+v", "UpdateRunStrategy", "Strategy", err)
	}

	return nil
}
