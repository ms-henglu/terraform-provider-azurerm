package springcloud

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/commonschema"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/identity"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/set"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceSpringCloudApp() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudAppCreate,
		Read:   resourceSpringCloudAppRead,
		Update: resourceSpringCloudAppUpdate,
		Delete: resourceSpringCloudAppDelete,

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := appplatform.ParseAppIDInsensitively(id)
			return err
		}),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.SpringCloudAppName,
			},

			"resource_group_name": commonschema.ResourceGroupName(),

			"service_name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.SpringCloudServiceName,
			},

			"addon_json": {
				Type:             pluginsdk.TypeString,
				Optional:         true,
				Computed:         true,
				ValidateFunc:     validation.StringIsJSON,
				DiffSuppressFunc: pluginsdk.SuppressJsonDiff,
			},

			"identity": commonschema.SystemAssignedUserAssignedIdentityOptional(),

			"custom_persistent_disk": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MinItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"storage_name": {
							Type:         schema.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},

						"mount_path": {
							Type:         schema.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},

						"share_name": {
							Type:         schema.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},

						"mount_options": {
							Type:     schema.TypeSet,
							Optional: true,
							Elem: &schema.Schema{
								Type:         schema.TypeString,
								ValidateFunc: validation.StringIsNotEmpty,
							},
						},

						"read_only_enabled": {
							Type:     schema.TypeBool,
							Optional: true,
							Default:  false,
						},
					},
				},
			},

			"is_public": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
				Default:  false,
			},

			"https_only": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
				Default:  false,
			},

			"persistent_disk": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				Computed: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"size_in_gb": {
							Type:         pluginsdk.TypeInt,
							Required:     true,
							ValidateFunc: validation.IntBetween(0, 50),
						},

						"mount_path": {
							Type:         pluginsdk.TypeString,
							Optional:     true,
							Default:      "/persistent",
							ValidateFunc: validate.MountPath,
						},
					},
				},
			},

			"public_endpoint_enabled": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
			},

			"tls_enabled": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
				Default:  false,
			},

			"fqdn": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},

			"url": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},
		},
	}
}

func resourceSpringCloudAppCreate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForCreate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id := appplatform.NewAppID(subscriptionId, d.Get("resource_group_name").(string), d.Get("service_name").(string), d.Get("name").(string))
	serviceResp, err := client.ServicesGet(ctx, appplatform.NewSpringID(id.SubscriptionId, id.ResourceGroupName, id.ServiceName))
	if err != nil {
		return fmt.Errorf("unable to retrieve %q: %+v", id, err)
	}

	if d.IsNewResource() {
		existing, err := client.AppsGet(ctx, id, appplatform.AppsGetOperationOptions{})
		if err != nil {
			if !response.WasNotFound(existing.HttpResponse) {
				return fmt.Errorf("checking for presence of existing %q: %+v", id, err)
			}
		}
		if !response.WasNotFound(existing.HttpResponse) {
			return tf.ImportAsExistsError("azurerm_spring_cloud_app", id.ID())
		}
	}

	identity, err := expandSpringCloudAppIdentity(d.Get("identity").([]interface{}))
	if err != nil {
		return err
	}

	addonConfig, err := expandSpringCloudAppAddon(d.Get("addon_json").(string))
	if err != nil {
		return err
	}

	app := appplatform.AppResource{
		Location: serviceResp.Model.Location,
		Identity: identity,
		Properties: &appplatform.AppResourceProperties{
			AddonConfigs:          addonConfig,
			EnableEndToEndTLS:     utils.Bool(d.Get("tls_enabled").(bool)),
			Public:                utils.Bool(d.Get("is_public").(bool)),
			CustomPersistentDisks: expandAppCustomPersistentDiskResourceArray(d.Get("custom_persistent_disk").([]interface{}), id),
		},
	}
	err = client.AppsCreateOrUpdateThenPoll(ctx, id, app)
	if err != nil {
		return fmt.Errorf("creating %q: %+v", id, err)
	}

	// HTTPSOnly and PersistentDisk could only be set by update
	app.Properties.HTTPSOnly = utils.Bool(d.Get("https_only").(bool))
	app.Properties.PersistentDisk = expandSpringCloudAppPersistentDisk(d.Get("persistent_disk").([]interface{}))
	// VNetAddons.PublicEndpoint could only be set by update
	if enabled := d.Get("public_endpoint_enabled").(bool); enabled {
		app.Properties.VnetAddons = &appplatform.AppVNetAddons{
			PublicEndpoint: utils.Bool(enabled),
		}
	}
	err = client.AppsCreateOrUpdateThenPoll(ctx, id, app)
	if err != nil {
		return fmt.Errorf("update %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceSpringCloudAppRead(d, meta)
}

func resourceSpringCloudAppUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseAppIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	identity, err := expandSpringCloudAppIdentity(d.Get("identity").([]interface{}))
	if err != nil {
		return err
	}

	addonConfig, err := expandSpringCloudAppAddon(d.Get("addon_json").(string))
	if err != nil {
		return err
	}

	app := appplatform.AppResource{
		Identity: identity,
		Properties: &appplatform.AppResourceProperties{
			AddonConfigs:          addonConfig,
			EnableEndToEndTLS:     utils.Bool(d.Get("tls_enabled").(bool)),
			Public:                utils.Bool(d.Get("is_public").(bool)),
			HTTPSOnly:             utils.Bool(d.Get("https_only").(bool)),
			PersistentDisk:        expandSpringCloudAppPersistentDisk(d.Get("persistent_disk").([]interface{})),
			CustomPersistentDisks: expandAppCustomPersistentDiskResourceArray(d.Get("custom_persistent_disk").([]interface{}), *id),
		},
	}
	if enabled := d.Get("public_endpoint_enabled").(bool); enabled {
		app.Properties.VnetAddons = &appplatform.AppVNetAddons{
			PublicEndpoint: utils.Bool(enabled),
		}
	}
	err = client.AppsCreateOrUpdateThenPoll(ctx, *id, app)
	if err != nil {
		return fmt.Errorf("update %s: %+v", id, err)
	}

	return resourceSpringCloudAppRead(d, meta)
}

func resourceSpringCloudAppRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseAppIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.AppsGet(ctx, *id, appplatform.AppsGetOperationOptions{})
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			log.Printf("[INFO] Spring Cloud App %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("reading %q: %+v", id, err)
	}

	d.Set("name", id.AppName)
	d.Set("service_name", id.ServiceName)
	d.Set("resource_group_name", id.ResourceGroupName)

	identity, err := flattenSpringCloudAppIdentity(resp.Model.Identity)
	if err != nil {
		return fmt.Errorf("flattening `identity`: %+v", err)
	}
	if err := d.Set("identity", identity); err != nil {
		return fmt.Errorf("setting `identity`: %s", err)
	}

	if prop := resp.Model.Properties; prop != nil {
		d.Set("is_public", prop.Public)
		d.Set("https_only", prop.HTTPSOnly)
		d.Set("fqdn", prop.Fqdn)
		d.Set("url", prop.Url)
		d.Set("tls_enabled", prop.EnableEndToEndTLS)
		if err := d.Set("addon_json", flattenSpringCloudAppAddon(prop.AddonConfigs)); err != nil {
			return fmt.Errorf("setting `addon_json`: %s", err)
		}
		if err := d.Set("persistent_disk", flattenSpringCloudAppPersistentDisk(prop.PersistentDisk)); err != nil {
			return fmt.Errorf("setting `persistent_disk`: %s", err)
		}
		if err := d.Set("custom_persistent_disk", flattenAppCustomPersistentDiskResourceArray(prop.CustomPersistentDisks)); err != nil {
			return fmt.Errorf("setting `custom_persistent_disk`: %+v", err)
		}
		if prop.VnetAddons != nil {
			d.Set("public_endpoint_enabled", prop.VnetAddons.PublicEndpoint)
		}
	}

	return nil
}

func resourceSpringCloudAppDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseAppIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	err = client.AppsDeleteThenPoll(ctx, *id)
	if err != nil {
		return fmt.Errorf("deleting %s: %+v", *id, err)
	}

	return nil
}

func expandSpringCloudAppIdentity(input []interface{}) (*identity.LegacySystemAndUserAssignedMap, error) {
	config, err := identity.ExpandSystemAndUserAssignedMap(input)
	if err != nil {
		return nil, err
	}

	out := identity.LegacySystemAndUserAssignedMap{
		Type: identity.Type(string(config.Type)),
	}
	if config.Type == identity.TypeUserAssigned || config.Type == identity.TypeSystemAssignedUserAssigned {
		out.IdentityIds = make(map[string]identity.UserAssignedIdentityDetails)
		for k := range config.IdentityIds {
			out.IdentityIds[k] = identity.UserAssignedIdentityDetails{
				// intentionally empty
			}
		}
	}

	return &out, nil
}

func expandSpringCloudAppPersistentDisk(input []interface{}) *appplatform.PersistentDisk {
	if len(input) == 0 || input[0] == nil {
		return nil
	}
	raw := input[0].(map[string]interface{})
	return &appplatform.PersistentDisk{
		SizeInGB:  utils.Int64(int64(raw["size_in_gb"].(int))),
		MountPath: utils.String(raw["mount_path"].(string)),
	}
}

func expandAppCustomPersistentDiskResourceArray(input []interface{}, id appplatform.AppId) *[]appplatform.CustomPersistentDiskResource {
	results := make([]appplatform.CustomPersistentDiskResource, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		results = append(results, appplatform.CustomPersistentDiskResource{
			StorageId: appplatform.NewStorageID(id.SubscriptionId, id.ResourceGroupName, id.ServiceName, v["storage_name"].(string)).ID(),
			CustomPersistentDiskProperties: &appplatform.AzureFileVolume{
				ShareName:    v["share_name"].(string),
				MountPath:    v["mount_path"].(string),
				ReadOnly:     utils.Bool(v["read_only_enabled"].(bool)),
				MountOptions: utils.ExpandStringSlice(v["mount_options"].(*pluginsdk.Set).List()),
			},
		})
	}
	return &results
}

func expandSpringCloudAppAddon(input string) (*map[string]map[string]interface{}, error) {
	var addonConfig map[string]map[string]interface{}
	if len(input) != 0 {
		err := json.Unmarshal([]byte(input), &addonConfig)
		if err != nil {
			return nil, fmt.Errorf("unable to unmarshal `addon_json`: %+v", err)
		}
	}
	return &addonConfig, nil
}

func flattenSpringCloudAppIdentity(input *identity.LegacySystemAndUserAssignedMap) (*[]interface{}, error) {
	var transform *identity.SystemAndUserAssignedMap
	if input != nil {
		transform = &identity.SystemAndUserAssignedMap{
			Type:        identity.Type(string(input.Type)),
			IdentityIds: make(map[string]identity.UserAssignedIdentityDetails),
		}
		transform.PrincipalId = input.PrincipalId
		transform.TenantId = input.TenantId
		for k, v := range input.IdentityIds {
			transform.IdentityIds[k] = identity.UserAssignedIdentityDetails{
				ClientId:    v.ClientId,
				PrincipalId: v.PrincipalId,
			}
		}
	}

	return identity.FlattenSystemAndUserAssignedMap(transform)
}

func flattenSpringCloudAppPersistentDisk(input *appplatform.PersistentDisk) []interface{} {
	if input == nil {
		return make([]interface{}, 0)
	}

	sizeInGB := 0
	if input.SizeInGB != nil {
		sizeInGB = int(*input.SizeInGB)
	}

	mountPath := ""
	if input.MountPath != nil {
		mountPath = *input.MountPath
	}

	return []interface{}{
		map[string]interface{}{
			"size_in_gb": sizeInGB,
			"mount_path": mountPath,
		},
	}
}

func flattenAppCustomPersistentDiskResourceArray(input *[]appplatform.CustomPersistentDiskResource) []interface{} {
	results := make([]interface{}, 0)
	if input == nil {
		return results
	}

	for _, item := range *input {
		var storageName string
		if id, err := appplatform.ParseStorageIDInsensitively(item.StorageId); err == nil {
			storageName = id.StorageName
		}
		var mountPath string
		var shareName string
		var readOnly bool
		var mountOptions *[]string
		if item.CustomPersistentDiskProperties != nil {
			if prop, ok := item.CustomPersistentDiskProperties.(appplatform.AzureFileVolume); ok {
				mountPath = prop.MountPath
				shareName = prop.ShareName
				if prop.ReadOnly != nil {
					readOnly = *prop.ReadOnly
				}
				mountOptions = prop.MountOptions
			}
		}

		results = append(results, map[string]interface{}{
			"storage_name":      storageName,
			"mount_path":        mountPath,
			"share_name":        shareName,
			"mount_options":     set.FromStringSliceNilable(mountOptions),
			"read_only_enabled": readOnly,
		})
	}
	return results
}

func flattenSpringCloudAppAddon(configs *map[string]map[string]interface{}) *string {
	if configs == nil || len(*configs) == 0 {
		return nil
	}
	addonConfig, _ := json.Marshal(*configs)
	return utils.String(string(addonConfig))
}
