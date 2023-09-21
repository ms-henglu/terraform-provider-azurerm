// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package datafactory

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/datafactory/2018-06-01/factories"
	"github.com/hashicorp/go-azure-sdk/resource-manager/datafactory/2018-06-01/globalparameters"
	"github.com/hashicorp/terraform-provider-azurerm/internal/sdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
)

var _ sdk.Resource = DataFactoryGlobalParameterResource{}

type DataFactoryGlobalParameterResource struct{}

type DataFactoryGlobalParameterResourceSchema struct {
	Name          string                             `tfschema:"name"`
	DataFactoryId string                             `tfschema:"data_factory_id"`
	Parameters    []DataFactoryGlobalParameterSchema `tfschema:"parameter"`
}

type DataFactoryGlobalParameterSchema struct {
	Name  string `tfschema:"name"`
	Type  string `tfschema:"type"`
	Value string `tfschema:"value"`
}

func (DataFactoryGlobalParameterResource) Arguments() map[string]*pluginsdk.Schema {
	return map[string]*pluginsdk.Schema{
		"name": {
			Type:         pluginsdk.TypeString,
			Required:     true,
			ForceNew:     true,
			ValidateFunc: validation.StringInSlice([]string{"default"}, false),
		},

		"data_factory_id": {
			Type:         pluginsdk.TypeString,
			Required:     true,
			ForceNew:     true,
			ValidateFunc: factories.ValidateFactoryID,
		},

		"parameter": {
			Type:     pluginsdk.TypeSet,
			Optional: true,
			Elem: &pluginsdk.Resource{
				Schema: map[string]*pluginsdk.Schema{
					"name": {
						Type:         pluginsdk.TypeString,
						Required:     true,
						ValidateFunc: validation.StringIsNotEmpty,
					},

					"type": {
						Type:         pluginsdk.TypeString,
						Required:     true,
						ValidateFunc: validation.StringInSlice(globalparameters.PossibleValuesForGlobalParameterType(), false),
					},

					"value": {
						Type:         pluginsdk.TypeString,
						Required:     true,
						ValidateFunc: validation.StringIsNotEmpty,
					},
				},
			},
		},
	}
}

func (DataFactoryGlobalParameterResource) Attributes() map[string]*pluginsdk.Schema {
	return map[string]*pluginsdk.Schema{}
}

func (DataFactoryGlobalParameterResource) ModelObject() interface{} {
	return &DataFactoryGlobalParameterResourceSchema{}
}

func (DataFactoryGlobalParameterResource) ResourceType() string {
	return "azurerm_data_factory_global_parameter"
}

func (r DataFactoryGlobalParameterResource) Create() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.DataFactory.GlobalParameters
			var data DataFactoryGlobalParameterResourceSchema
			if err := metadata.Decode(&data); err != nil {
				return fmt.Errorf("decoding: %+v", err)
			}

			dataFactoryId, err := factories.ParseFactoryID(data.DataFactoryId)
			if err != nil {
				return err
			}

			id := globalparameters.NewGlobalParameterID(dataFactoryId.SubscriptionId, dataFactoryId.ResourceGroupName, dataFactoryId.FactoryName, data.Name)

			existing, err := client.Get(ctx, id)
			if err != nil {
				if !response.WasNotFound(existing.HttpResponse) {
					return fmt.Errorf("checking for presence of existing %s: %+v", id, err)
				}
			}
			if !response.WasNotFound(existing.HttpResponse) {
				return metadata.ResourceRequiresImport(r.ResourceType(), id)
			}

			parameters, err := expandGlobalParameters(data.Parameters)
			if err != nil {
				return err
			}

			resource := globalparameters.GlobalParameterResource{
				Properties: *parameters,
			}

			if _, err := client.CreateOrUpdate(ctx, id, resource); err != nil {
				return fmt.Errorf("creating %s: %+v", id, err)
			}

			metadata.SetID(id)
			return nil
		},
	}
}

func (r DataFactoryGlobalParameterResource) Update() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			client := metadata.Client.DataFactory.GlobalParameters
			id, err := globalparameters.ParseGlobalParameterID(metadata.ResourceData.Id())
			if err != nil {
				return err
			}
			var data DataFactoryGlobalParameterResourceSchema
			if err := metadata.Decode(&data); err != nil {
				return fmt.Errorf("decoding: %+v", err)
			}

			resource, err := client.Get(ctx, *id)
			if err != nil {
				return fmt.Errorf("retrieving existing %s: %+v", id, err)
			}

			if metadata.ResourceData.HasChange("global_parameter") {
				parameters, err := expandGlobalParameters(data.Parameters)
				if err != nil {
					return err
				}

				resource.Model.Properties = *parameters
			}

			if _, err := client.CreateOrUpdate(ctx, *id, *resource.Model); err != nil {
				return fmt.Errorf("updating %s: %+v", id, err)
			}

			metadata.SetID(id)
			return nil
		},
	}
}

func (DataFactoryGlobalParameterResource) Read() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 5 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			d := metadata.ResourceData
			client := metadata.Client.DataFactory.GlobalParameters
			id, err := globalparameters.ParseGlobalParameterID(d.Id())
			if err != nil {
				return err
			}

			var state DataFactoryGlobalParameterResourceSchema

			resp, err := client.Get(ctx, *id)
			if err != nil {
				if response.WasNotFound(resp.HttpResponse) {
					return metadata.MarkAsGone(id)
				}

				return fmt.Errorf("retrieving %s: %+v", id, err)
			}

			state.Name = id.GlobalParameterName
			state.DataFactoryId = globalparameters.NewFactoryID(id.SubscriptionId, id.ResourceGroupName, id.FactoryName).ID()

			parameters, err := flattenGlobalParameters(resp.Model.Properties)
			if err != nil {
				return err
			}
			state.Parameters = parameters

			return metadata.Encode(&state)
		},
	}
}

func (DataFactoryGlobalParameterResource) Delete() sdk.ResourceFunc {
	return sdk.ResourceFunc{
		Timeout: 30 * time.Minute,
		Func: func(ctx context.Context, metadata sdk.ResourceMetaData) error {
			d := metadata.ResourceData
			client := metadata.Client.DataFactory.GlobalParameters

			id, err := globalparameters.ParseGlobalParameterID(d.Id())
			if err != nil {
				return err
			}

			resp, err := client.Delete(ctx, *id)
			if err != nil {
				if !response.WasNotFound(resp.HttpResponse) {
					return fmt.Errorf("deleting %s: %+v", *id, err)
				}
			}

			return nil
		},
	}
}

func (DataFactoryGlobalParameterResource) IDValidationFunc() pluginsdk.SchemaValidateFunc {
	return globalparameters.ValidateGlobalParameterID
}

func expandGlobalParameters(input []DataFactoryGlobalParameterSchema) (*map[string]globalparameters.GlobalParameterSpecification, error) {
	result := make(map[string]globalparameters.GlobalParameterSpecification)
	if len(input) == 0 {
		return &result, nil
	}
	for _, item := range input {
		name := item.Name
		if _, ok := result[name]; ok {
			return nil, fmt.Errorf("duplicate parameter name")
		}

		result[name] = globalparameters.GlobalParameterSpecification{
			Type:  globalparameters.GlobalParameterType(item.Type),
			Value: item.Value,
		}
	}
	return &result, nil
}

func flattenGlobalParameters(input map[string]globalparameters.GlobalParameterSpecification) ([]DataFactoryGlobalParameterSchema, error) {
	if input == nil {
		return nil, nil
	}
	result := make([]DataFactoryGlobalParameterSchema, 0)
	for name, item := range input {
		var valueResult string
		_, valueIsString := item.Value.(string)
		if (item.Type == globalparameters.GlobalParameterTypeArray || item.Type == globalparameters.GlobalParameterTypeObject) && !valueIsString {
			bytes, err := json.Marshal(item.Value)
			if err != nil {
				return nil, fmt.Errorf("marshalling value for global parameter %q (value %+v): %+v", name, item.Value, err)
			}
			valueResult = string(bytes)
		} else {
			valueResult = fmt.Sprintf("%v", item.Value)
		}
		result = append(result, DataFactoryGlobalParameterSchema{
			Name:  name,
			Type:  string(item.Type),
			Value: valueResult,
		})
	}
	return result, nil
}
