package monitor

import (
	"fmt"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/monitor/mgmt/2021-04-01-preview/insights"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tags"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceMonitorDataCollectionEndpoint() *schema.Resource {
	return &schema.Resource{
		Create: resourceMonitorDataCollectionEndpointCreateUpdate,
		Read:   resourceMonitorDataCollectionEndpointRead,
		Update: resourceMonitorDataCollectionEndpointCreateUpdate,
		Delete: resourceMonitorDataCollectionEndpointDelete,
		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.DataCollectionEndpointID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"location": azure.SchemaLocation(),

			"description": {
				Type:         schema.TypeString,
				Optional:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"kind": {
				Type:     schema.TypeString,
				Optional: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(insights.Windows),
					string(insights.Linux),
				}, false),
			},

			"public_network_access_enabled": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
				Default:  true,
			},

			"configuration_access_endpoint": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},

			"logs_ingestion_endpoint": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},

			"tags": tags.Schema(),
		},
	}
}

func resourceMonitorDataCollectionEndpointCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Monitor.DataCollectionEndpointsClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)

	id := parse.NewDataCollectionEndpointID(subscriptionId, resourceGroup, name)
	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Monitor DataCollectionEndpoint %q: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_monitor_data_collection_endpoint", id.ID())
		}

	}

	publicNetworkAccess := insights.KnownPublicNetworkAccessOptionsEnabled
	if !d.Get("public_network_access_enabled").(bool) {
		publicNetworkAccess = insights.KnownPublicNetworkAccessOptionsDisabled
	}

	body := insights.DataCollectionEndpointResource{
		DataCollectionEndpointResourceProperties: &insights.DataCollectionEndpointResourceProperties{
			Description: utils.String(d.Get("description").(string)),
			NetworkAcls: &insights.DataCollectionEndpointNetworkAcls{PublicNetworkAccess: publicNetworkAccess},
		},
		Location: utils.String(location.Normalize(d.Get("location").(string))),
		Tags:     tags.Expand(d.Get("tags").(map[string]interface{})),
	}

	if kind, ok := d.GetOk("kind"); ok {
		body.Kind = insights.KnownDataCollectionEndpointResourceKind(kind.(string))
	}
	_, err := client.Create(ctx, id.ResourceGroup, id.Name, &body)
	if err != nil {
		return fmt.Errorf("creating Monitor DataCollectionEndpoint %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceMonitorDataCollectionEndpointRead(d, meta)
}

func resourceMonitorDataCollectionEndpointRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionEndpointsClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionEndpointID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] Monitor DataCollectionEndpoint %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Monitor DataCollectionEndpoint %q: %+v", id, err)
	}

	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("location", location.NormalizeNilable(resp.Location))
	if resp.Description != nil {
		d.Set("description", *resp.Description)
	}
	d.Set("kind", resp.Kind)
	publicNetworkAccessEnabled := true
	if props := resp.DataCollectionEndpointResourceProperties; props != nil {
		if props.NetworkAcls != nil {
			publicNetworkAccessEnabled = props.NetworkAcls.PublicNetworkAccess == insights.KnownPublicNetworkAccessOptionsEnabled
		}
		if props.ConfigurationAccess != nil && props.ConfigurationAccess.Endpoint != nil {
			d.Set("configuration_access_endpoint", *props.ConfigurationAccess.Endpoint)
		}
		if props.LogsIngestion != nil && props.LogsIngestion.Endpoint != nil {
			d.Set("logs_ingestion_endpoint", *props.LogsIngestion.Endpoint)
		}
	}

	d.Set("public_network_access_enabled", publicNetworkAccessEnabled)

	return tags.FlattenAndSet(d, resp.Tags)
}

func resourceMonitorDataCollectionEndpointDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionEndpointsClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionEndpointID(d.Id())
	if err != nil {
		return err
	}

	_, err = client.Delete(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return fmt.Errorf("deleting Monitor DataCollectionEndpoint %q: %+v", id, err)
	}

	return nil
}
