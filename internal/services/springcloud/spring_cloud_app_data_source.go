package springcloud

import (
	"fmt"
	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"time"

	"github.com/hashicorp/go-azure-helpers/resourcemanager/commonschema"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
)

func dataSourceSpringCloudApp() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Read: dataSourceSpringCloudAppRead,

		Timeouts: &pluginsdk.ResourceTimeout{
			Read: pluginsdk.DefaultTimeout(5 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validate.SpringCloudAppName,
			},

			"resource_group_name": commonschema.ResourceGroupNameForDataSource(),

			"service_name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validate.SpringCloudServiceName,
			},

			"fqdn": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},

			"https_only": {
				Type:     pluginsdk.TypeBool,
				Computed: true,
			},

			"identity": commonschema.SystemAssignedUserAssignedIdentityComputed(),

			"is_public": {
				Type:     pluginsdk.TypeBool,
				Computed: true,
			},

			"persistent_disk": {
				Type:     pluginsdk.TypeList,
				Computed: true,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"mount_path": {
							Type:     pluginsdk.TypeString,
							Computed: true,
						},

						"size_in_gb": {
							Type:     pluginsdk.TypeInt,
							Computed: true,
						},
					},
				},
			},

			"tls_enabled": {
				Type:     pluginsdk.TypeBool,
				Computed: true,
			},

			"url": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},
		},
	}
}

func dataSourceSpringCloudAppRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id := appplatform.NewAppID(subscriptionId, d.Get("resource_group_name").(string), d.Get("service_name").(string), d.Get("name").(string))

	resp, err := client.AppsGet(ctx, id, appplatform.AppsGetOperationOptions{})
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			return fmt.Errorf("%s was not found", id)
		}
		return fmt.Errorf("retrieving %s: %+v", id, err)
	}

	d.SetId(id.ID())

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
		d.Set("fqdn", prop.Fqdn)
		d.Set("https_only", prop.HTTPSOnly)
		d.Set("is_public", prop.Public)
		d.Set("url", prop.Url)
		d.Set("tls_enabled", prop.EnableEndToEndTLS)

		if err := d.Set("persistent_disk", flattenSpringCloudAppPersistentDisk(prop.PersistentDisk)); err != nil {
			return fmt.Errorf("setting `persistent_disk`: %s", err)
		}
	}

	return nil
}
