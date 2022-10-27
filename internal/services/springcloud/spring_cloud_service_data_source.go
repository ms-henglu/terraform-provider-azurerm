package springcloud

import (
	"fmt"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/commonschema"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/location"
	"github.com/hashicorp/go-azure-helpers/resourcemanager/tags"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
)

func dataSourceSpringCloudService() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Read: dataSourceSpringCloudServiceRead,

		Timeouts: &pluginsdk.ResourceTimeout{
			Read: pluginsdk.DefaultTimeout(5 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validate.SpringCloudServiceName,
			},

			"location": commonschema.LocationComputed(),

			"resource_group_name": commonschema.ResourceGroupNameForDataSource(),

			"config_server_git_setting": {
				Type:     pluginsdk.TypeList,
				Computed: true,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"uri": {
							Type:     pluginsdk.TypeString,
							Computed: true,
						},

						"label": {
							Type:     pluginsdk.TypeString,
							Computed: true,
						},

						"search_paths": {
							Type:     pluginsdk.TypeList,
							Computed: true,
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},

						"http_basic_auth": DataSourceSchemaConfigServerHttpBasicAuth(),

						"ssh_auth": DataSourceSchemaConfigServerSSHAuth(),

						"repository": {
							Type:     pluginsdk.TypeList,
							Computed: true,
							Elem: &pluginsdk.Resource{
								Schema: map[string]*pluginsdk.Schema{
									"name": {
										Type:     pluginsdk.TypeString,
										Computed: true,
									},
									"uri": {
										Type:     pluginsdk.TypeString,
										Computed: true,
									},
									"label": {
										Type:     pluginsdk.TypeString,
										Computed: true,
									},
									"pattern": {
										Type:     pluginsdk.TypeList,
										Computed: true,
										Elem: &pluginsdk.Schema{
											Type: pluginsdk.TypeString,
										},
									},
									"search_paths": {
										Type:     pluginsdk.TypeList,
										Computed: true,
										Elem: &pluginsdk.Schema{
											Type: pluginsdk.TypeString,
										},
									},

									"http_basic_auth": DataSourceSchemaConfigServerHttpBasicAuth(),

									"ssh_auth": DataSourceSchemaConfigServerSSHAuth(),
								},
							},
						},
					},
				},
			},

			"outbound_public_ip_addresses": {
				Type:     pluginsdk.TypeList,
				Computed: true,
				Elem: &pluginsdk.Schema{
					Type: pluginsdk.TypeString,
				},
			},

			"required_network_traffic_rules": {
				Type:     pluginsdk.TypeList,
				Computed: true,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"protocol": {
							Type:     pluginsdk.TypeString,
							Computed: true,
						},

						"port": {
							Type:     pluginsdk.TypeInt,
							Computed: true,
						},

						"ip_addresses": {
							Type:     pluginsdk.TypeList,
							Computed: true,
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},

						"fqdns": {
							Type:     pluginsdk.TypeList,
							Computed: true,
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},

						"direction": {
							Type:     pluginsdk.TypeString,
							Computed: true,
						},
					},
				},
			},

			"tags": commonschema.TagsDataSource(),
		},
	}
}

func dataSourceSpringCloudServiceRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id := appplatform.NewSpringID(subscriptionId, d.Get("resource_group_name").(string), d.Get("name").(string))

	resp, err := client.ServicesGet(ctx, id)
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			return fmt.Errorf("%s was not found", id)
		}
		return fmt.Errorf("retrieving %s: %+v", id, err)
	}

	d.SetId(id.ID())

	d.Set("name", id.ServiceName)
	d.Set("resource_group_name", id.ResourceGroupName)
	d.Set("location", location.NormalizeNilable(resp.Model.Location))

	if resp.Model.Sku != nil && resp.Model.Sku.Name != nil && *resp.Model.Sku.Name != "E0" {
		configServer, err := client.ConfigServersGet(ctx, id)
		if err != nil {
			return fmt.Errorf("retrieving config server configuration for %s: %+v", id, err)
		}
		if err := d.Set("config_server_git_setting", flattenSpringCloudConfigServerGitProperty(configServer.Model.Properties, d)); err != nil {
			return fmt.Errorf("setting `config_server_git_setting`: %+v", err)
		}
	}

	if props := resp.Model.Properties; props != nil {
		outboundPublicIPAddresses := flattenOutboundPublicIPAddresses(props.NetworkProfile)
		if err := d.Set("outbound_public_ip_addresses", outboundPublicIPAddresses); err != nil {
			return fmt.Errorf("setting `outbound_public_ip_addresses`: %+v", err)
		}

		if err := d.Set("required_network_traffic_rules", flattenRequiredTraffic(props.NetworkProfile)); err != nil {
			return fmt.Errorf("setting `required_network_traffic_rules`: %+v", err)
		}
	}

	return tags.FlattenAndSet(d, resp.Model.Tags)
}
