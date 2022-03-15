package springcloud

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/appplatform/mgmt/2022-03-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceSpringCloudBuildpackBinding() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudBuildpackBindingCreateUpdate,
		Read:   resourceSpringCloudBuildpackBindingRead,
		Update: resourceSpringCloudBuildpackBindingCreateUpdate,
		Delete: resourceSpringCloudBuildpackBindingDelete,

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := parse.SpringCloudBuildpackBindingID(id)
			return err
		}),

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
			},

			"spring_cloud_builder_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.SpringCloudBuildServiceBuilderID,
			},

			"binding_type": {
				Type:     pluginsdk.TypeString,
				Optional: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(appplatform.BindingTypeApplicationInsights),
					string(appplatform.BindingTypeApacheSkyWalking),
					string(appplatform.BindingTypeAppDynamics),
					string(appplatform.BindingTypeDynatrace),
					string(appplatform.BindingTypeNewRelic),
					string(appplatform.BindingTypeElasticAPM),
				}, false),
			},

			"launch_properties": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"properties": {
							Type:     pluginsdk.TypeMap,
							Optional: true,
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},

						"secrets": {
							Type:     pluginsdk.TypeMap,
							Optional: true,
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},
					},
				},
			},
		},
	}
}
func resourceSpringCloudBuildpackBindingCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).AppPlatform.BuildpackBindingClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	builderId, err := parse.SpringCloudBuildServiceBuilderID(d.Get("spring_cloud_builder_id").(string))
	if err != nil {
		return err
	}
	id := parse.NewSpringCloudBuildpackBindingID(subscriptionId, builderId.ResourceGroup, builderId.SpringName, builderId.BuildServiceName, builderId.BuilderName, d.Get("name").(string))

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName, id.BuildpackBindingName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing %s: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_spring_cloud_buildpack_binding", id.ID())
		}
	}

	buildpackBinding := appplatform.BuildpackBindingResource{
		Properties: &appplatform.BuildpackBindingProperties{
			BindingType:      appplatform.BindingType(d.Get("binding_type").(string)),
			LaunchProperties: expandBuildpackBindingBuildpackBindingLaunchProperties(d.Get("launch_properties").([]interface{})),
		},
	}
	future, err := client.CreateOrUpdate(ctx, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName, id.BuildpackBindingName, buildpackBinding)
	if err != nil {
		return fmt.Errorf("creating/updating %s: %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for creation/update of %s: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceSpringCloudBuildpackBindingRead(d, meta)
}

func resourceSpringCloudBuildpackBindingRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.BuildpackBindingClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.SpringCloudBuildpackBindingID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName, id.BuildpackBindingName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] appplatform %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving %s: %+v", id, err)
	}
	d.Set("name", id.BuildpackBindingName)
	d.Set("spring_cloud_builder_id", parse.NewSpringCloudBuildServiceBuilderID(id.SubscriptionId, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName).ID())
	if props := resp.Properties; props != nil {
		d.Set("binding_type", props.BindingType)
		if err := d.Set("launch_properties", flattenBuildpackBindingBuildpackBindingLaunchProperties(props.LaunchProperties)); err != nil {
			return fmt.Errorf("setting `launch_properties`: %+v", err)
		}
	}
	return nil
}

func resourceSpringCloudBuildpackBindingDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.BuildpackBindingClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.SpringCloudBuildpackBindingID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.Delete(ctx, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName, id.BuildpackBindingName)
	if err != nil {
		return fmt.Errorf("deleting %s: %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for deletion of %s: %+v", id, err)
	}
	return nil
}

func expandBuildpackBindingBuildpackBindingLaunchProperties(input []interface{}) *appplatform.BuildpackBindingLaunchProperties {
	if len(input) == 0 {
		return nil
	}
	v := input[0].(map[string]interface{})
	return &appplatform.BuildpackBindingLaunchProperties{
		Properties: utils.ExpandMapStringPtrString(v["properties"].(map[string]interface{})),
		Secrets:    utils.ExpandMapStringPtrString(v["secrets"].(map[string]interface{})),
	}
}

func flattenBuildpackBindingBuildpackBindingLaunchProperties(input *appplatform.BuildpackBindingLaunchProperties) []interface{} {
	if input == nil {
		return make([]interface{}, 0)
	}

	props := make(map[string]interface{})
	if input.Properties != nil {
		props = utils.FlattenMapStringPtrString(input.Properties)
	}
	secrets := make(map[string]interface{})
	if input.Secrets != nil {
		secrets = utils.FlattenMapStringPtrString(input.Secrets)
	}
	return []interface{}{
		map[string]interface{}{
			"properties": props,
			"secrets":    secrets,
		},
	}
}
