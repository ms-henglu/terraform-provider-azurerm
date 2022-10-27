package springcloud

import (
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceSpringCloudJavaDeployment() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudJavaDeploymentCreate,
		Read:   resourceSpringCloudJavaDeploymentRead,
		Update: resourceSpringCloudJavaDeploymentUpdate,
		Delete: resourceSpringCloudJavaDeploymentDelete,

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := appplatform.ParseDeploymentIDInsensitively(id)
			return err
		}),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: resourceSprintCloudJavaDeploymentSchema(),
	}
}

func resourceSpringCloudJavaDeploymentCreate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForCreate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	appId, err := appplatform.ParseAppIDInsensitively(d.Get("spring_cloud_app_id").(string))
	if err != nil {
		return err
	}

	id := appplatform.NewDeploymentID(subscriptionId, appId.ResourceGroupName, appId.ServiceName, appId.AppName, d.Get("name").(string))
	existing, err := client.DeploymentsGet(ctx, id)
	if err != nil {
		if !response.WasNotFound(existing.HttpResponse) {
			return fmt.Errorf("checking for presence of existing %s: %+v", id, err)
		}
	}
	if !response.WasNotFound(existing.HttpResponse) {
		return tf.ImportAsExistsError("azurerm_spring_cloud_java_deployment", id.ID())
	}

	service, err := client.ServicesGet(ctx, appplatform.NewSpringID(appId.SubscriptionId, appId.ResourceGroupName, appId.ServiceName))
	if err != nil {
		return fmt.Errorf("checking for presence of existing %q: %+v", appId, err)
	}
	if service.Model.Sku == nil || service.Model.Sku.Name == nil || service.Model.Sku.Tier == nil {
		return fmt.Errorf("invalid `sku` for %q", appId)
	}

	deployment := appplatform.DeploymentResource{
		Sku: &appplatform.Sku{
			Name:     service.Model.Sku.Name,
			Tier:     service.Model.Sku.Tier,
			Capacity: utils.Int64(int64(d.Get("instance_count").(int))),
		},
		Properties: &appplatform.DeploymentResourceProperties{
			//		Source: appplatform.UserSourceInfo{
			//		RuntimeVersion: utils.String(d.Get("runtime_version").(string)),
			//		JvmOptions:     utils.String(d.Get("jvm_options").(string)),
			//	RelativePath:   utils.String("<default>"),
			//	Type:           appplatform.TypeBasicUserSourceInfoTypeJar,
			//		},
			DeploymentSettings: &appplatform.DeploymentSettings{
				EnvironmentVariables: expandSpringCloudDeploymentEnvironmentVariables(d.Get("environment_variables").(map[string]interface{})),
				ResourceRequests:     expandSpringCloudDeploymentResourceRequests(d.Get("quota").([]interface{})),
			},
		},
	}

	err = client.DeploymentsCreateOrUpdateThenPoll(ctx, id, deployment)
	if err != nil {
		return fmt.Errorf("creating %s: %+v", id, err)
	}

	d.SetId(id.ID())

	return resourceSpringCloudJavaDeploymentRead(d, meta)
}

func resourceSpringCloudJavaDeploymentUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseDeploymentIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	existing, err := client.DeploymentsGet(ctx, *id)
	if err != nil {
		return fmt.Errorf("reading existing %s: %+v", id, err)
	}
	if existing.Model.Sku == nil || existing.Model.Properties == nil || existing.Model.Properties.DeploymentSettings == nil {
		return fmt.Errorf("nil `sku`, `properties` or `properties.deploymentSettings` for %s: %+v", id, err)
	}

	if d.HasChange("instance_count") {
		existing.Model.Sku.Capacity = utils.Int64(int64(d.Get("instance_count").(int)))
	}

	if d.HasChange("cpu") {
		if existing.Model.Properties.DeploymentSettings.ResourceRequests != nil {
			existing.Model.Properties.DeploymentSettings.ResourceRequests.Cpu = utils.String(strconv.Itoa(d.Get("cpu").(int)))
		}
	}

	if d.HasChange("environment_variables") {
		existing.Model.Properties.DeploymentSettings.EnvironmentVariables = expandSpringCloudDeploymentEnvironmentVariables(d.Get("environment_variables").(map[string]interface{}))
	}

	if d.HasChange("jvm_options") {
		//	if source, ok := existing.Model.Properties.Source.AsJarUploadedUserSourceInfo(); ok {
		//		source.JvmOptions = utils.String(d.Get("jvm_options").(string))
		//		existing.Model.Properties.Source = source
		//	}
	}

	if d.HasChange("memory_in_gb") {
		if existing.Model.Properties.DeploymentSettings.ResourceRequests != nil {
			existing.Model.Properties.DeploymentSettings.ResourceRequests.Memory = utils.String(fmt.Sprintf("%dGi", d.Get("memory_in_gb").(int)))
		}
	}

	if d.HasChange("quota") {
		if existing.Model.Properties.DeploymentSettings.ResourceRequests == nil {
			return fmt.Errorf("nil `properties.deploymentSettings.resourceRequests` for %s: %+v", id, err)
		}

		existing.Model.Properties.DeploymentSettings.ResourceRequests = expandSpringCloudDeploymentResourceRequests(d.Get("quota").([]interface{}))
	}

	if d.HasChange("runtime_version") {
		//if source, ok := existing.Properties.Source.AsJarUploadedUserSourceInfo(); ok {
		//	source.RuntimeVersion = utils.String(d.Get("runtime_version").(string))
		//	existing.Properties.Source = source
		//}
	}

	//err = client.DeploymentsCreateOrUpdateThenPoll(ctx, *id, existing)
	if err != nil {
		return fmt.Errorf("updating %s: %+v", id, err)
	}

	return resourceSpringCloudJavaDeploymentRead(d, meta)
}

func resourceSpringCloudJavaDeploymentRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseDeploymentIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.DeploymentsGet(ctx, *id)
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			log.Printf("[INFO] Spring Cloud deployment %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("reading %q: %+v", id, err)
	}

	d.Set("name", id.DeploymentName)
	d.Set("spring_cloud_app_id", appplatform.NewAppID(id.SubscriptionId, id.ResourceGroupName, id.ServiceName, id.AppName).ID())
	if resp.Model.Sku != nil {
		d.Set("instance_count", resp.Model.Sku.Capacity)
	}
	if resp.Model.Properties != nil {
		if settings := resp.Model.Properties.DeploymentSettings; settings != nil {
			d.Set("environment_variables", flattenSpringCloudDeploymentEnvironmentVariables(settings.EnvironmentVariables))
			if err := d.Set("quota", flattenSpringCloudDeploymentResourceRequests(settings.ResourceRequests)); err != nil {
				return fmt.Errorf("setting `quota`: %+v", err)
			}
		}
		//	if source, ok := resp.Model.Properties.Source.AsJarUploadedUserSourceInfo(); ok && source != nil {
		//		d.Set("jvm_options", source.JvmOptions)
		//		d.Set("runtime_version", source.RuntimeVersion)
		//	}
	}

	return nil
}

func resourceSpringCloudJavaDeploymentDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseDeploymentIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	err = client.DeploymentsDeleteThenPoll(ctx, *id)
	if err != nil {
		return fmt.Errorf("deleting %q: %+v", id, err)
	}

	return nil
}

func expandSpringCloudDeploymentEnvironmentVariables(envMap map[string]interface{}) *map[string]string {
	output := make(map[string]string, len(envMap))

	for k, v := range envMap {
		output[k] = v.(string)
	}

	return &output
}

func flattenSpringCloudDeploymentEnvironmentVariables(envMap *map[string]string) map[string]interface{} {
	if envMap == nil {
		return make(map[string]interface{})
	}
	output := make(map[string]interface{}, len(*envMap))
	for i, v := range *envMap {
		output[i] = v
	}
	return output
}

func expandSpringCloudDeploymentResourceRequests(input []interface{}) *appplatform.ResourceRequests {
	cpuResult := "1"   // default value that's aligned with previous behavior used to be defined in schema.
	memResult := "1Gi" // default value that's aligned with previous behavior used to be defined in schema.

	if len(input) > 0 && input[0] != nil {
		v := input[0].(map[string]interface{})
		if v != nil {
			if cpuNew := v["cpu"].(string); cpuNew != "" {
				cpuResult = cpuNew
			}

			if memoryNew := v["memory"].(string); memoryNew != "" {
				memResult = memoryNew
			}
		}
	}

	result := appplatform.ResourceRequests{
		Cpu:    utils.String(cpuResult),
		Memory: utils.String(memResult),
	}

	return &result
}

func flattenSpringCloudDeploymentResourceRequests(input *appplatform.ResourceRequests) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	cpu := ""
	if input.Cpu != nil {
		cpu = *input.Cpu
	}

	memory := ""
	if input.Memory != nil {
		memory = *input.Memory
	}

	return []interface{}{
		map[string]interface{}{
			"cpu":    cpu,
			"memory": memory,
		},
	}
}

func resourceSprintCloudJavaDeploymentSchema() map[string]*pluginsdk.Schema {
	return map[string]*pluginsdk.Schema{
		"name": {
			Type:         pluginsdk.TypeString,
			Required:     true,
			ForceNew:     true,
			ValidateFunc: validate.SpringCloudDeploymentName,
		},

		"spring_cloud_app_id": {
			Type:         pluginsdk.TypeString,
			Required:     true,
			ForceNew:     true,
			ValidateFunc: validate.SpringCloudAppID,
		},

		"environment_variables": {
			Type:     pluginsdk.TypeMap,
			Optional: true,
			Elem: &pluginsdk.Schema{
				Type: pluginsdk.TypeString,
			},
		},

		"instance_count": {
			Type:         pluginsdk.TypeInt,
			Optional:     true,
			Default:      1,
			ValidateFunc: validation.IntBetween(1, 500),
		},

		"jvm_options": {
			Type:     pluginsdk.TypeString,
			Optional: true,
		},

		"quota": {
			Type:     pluginsdk.TypeList,
			Optional: true,
			Computed: true,
			MaxItems: 1,
			Elem: &pluginsdk.Resource{
				Schema: map[string]*pluginsdk.Schema{
					// The value returned in GET will be recalculated by the service if the deprecated "cpu" is honored, so make this property as Computed.
					"cpu": {
						Type:     pluginsdk.TypeString,
						Optional: true,
						Computed: true,
						// NOTE: we're intentionally not validating this field since additional values are possible when enabled by the service team
						ValidateFunc: validation.StringIsNotEmpty,
					},

					// The value returned in GET will be recalculated by the service if the deprecated "memory_in_gb" is honored, so make this property as Computed.
					"memory": {
						Type:     pluginsdk.TypeString,
						Optional: true,
						Computed: true,
						// NOTE: we're intentionally not validating this field since additional values are possible when enabled by the service team
						ValidateFunc: validation.StringIsNotEmpty,
					},
				},
			},
		},

		"runtime_version": {
			Type:     pluginsdk.TypeString,
			Optional: true,
			ValidateFunc: validation.StringInSlice([]string{
				string(appplatform.SupportedRuntimeValueJavaEight),
				string(appplatform.SupportedRuntimeValueJavaOneOne),
				string(appplatform.SupportedRuntimeValueJavaOneSeven),
			}, false),
			Default: appplatform.SupportedRuntimeValueJavaEight,
		},
	}
}
