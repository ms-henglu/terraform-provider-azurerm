package network

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/network/parse"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceNetworkConnectivityConfiguration() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkConnectivityConfigurationCreateUpdate,
		Read:   resourceNetworkConnectivityConfigurationRead,
		Update: resourceNetworkConnectivityConfigurationCreateUpdate,
		Delete: resourceNetworkConnectivityConfigurationDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkConnectivityConfigurationID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"network_manager_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"applies_to_groups": {
				Type:     schema.TypeList,
				Required: true,
				MinItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"network_group_id": {
							Type:     schema.TypeString,
							Required: true,
						},

						"group_connectivity": {
							Type:     schema.TypeString,
							Optional: true,
							ValidateFunc: validation.StringInSlice([]string{
								string(network.GroupConnectivityNone),
								string(network.GroupConnectivityDirectlyConnected),
							}, false),
						},

						"is_global": {
							Type:     schema.TypeBool,
							Optional: true,
						},

						"use_hub_gateway": {
							Type:     schema.TypeBool,
							Optional: true,
						},
					},
				},
			},

			"connectivity_topology": {
				Type:     schema.TypeString,
				Required: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.HubAndSpoke),
					string(network.Mesh),
				}, false),
			},

			"delete_existing_peering": {
				Type:     schema.TypeBool,
				Optional: true,
			},

			"description": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"display_name": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"hub_id": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"is_global": {
				Type:     schema.TypeBool,
				Optional: true,
			},
		},
	}
}
func resourceNetworkConnectivityConfigurationCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.ConnectivityConfigurationClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)

	id := parse.NewNetworkConnectivityConfigurationID(subscriptionId, resourceGroup, networkManagerName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network ConnectivityConfiguration (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_connectivity_configuration", id.ID())
		}
	}

	deleteExistingPeering := network.DeleteExistingPeeringFalse
	if !d.Get("delete_existing_peering").(bool) {
		deleteExistingPeering = network.DeleteExistingPeeringTrue
	}
	isGlobal := network.IsGlobalFalse
	if !d.Get("delete_existing_peering").(bool) {
		isGlobal = network.IsGlobalTrue
	}
	connectivityConfiguration := network.ConnectivityConfiguration{
		ConnectivityConfigurationProperties: &network.ConnectivityConfigurationProperties{
			AppliesToGroups:       expandConnectivityConfigurationConnectivityGroupItemArray(d.Get("applies_to_groups").([]interface{})),
			ConnectivityTopology:  network.ConnectivityTopology(d.Get("connectivity_topology").(string)),
			DeleteExistingPeering: deleteExistingPeering,
			Description:           utils.String(d.Get("description").(string)),
			DisplayName:           utils.String(d.Get("display_name").(string)),
			HubID:                 utils.String(d.Get("hub_id").(string)),
			IsGlobal:              isGlobal,
		},
	}
	if _, err := client.CreateOrUpdate(ctx, connectivityConfiguration, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName); err != nil {
		return fmt.Errorf("creating/updating Network ConnectivityConfiguration (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkConnectivityConfigurationRead(d, meta)
}

func resourceNetworkConnectivityConfigurationRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.ConnectivityConfigurationClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkConnectivityConfigurationID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network ConnectivityConfiguration (%q): %+v", id, err)
	}
	d.Set("name", id.ConnectivityConfigurationName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("network_manager_name", id.NetworkManagerName)
	if props := resp.ConnectivityConfigurationProperties; props != nil {
		if err := d.Set("applies_to_groups", flattenConnectivityConfigurationConnectivityGroupItemArray(props.AppliesToGroups)); err != nil {
			return fmt.Errorf("setting `applies_to_groups`: %+v", err)
		}
		d.Set("connectivity_topology", props.ConnectivityTopology)
		d.Set("delete_existing_peering", props.DeleteExistingPeering)
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
		d.Set("hub_id", props.HubID)
		d.Set("is_global", props.IsGlobal)
	}
	return nil
}

func resourceNetworkConnectivityConfigurationDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.ConnectivityConfigurationClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkConnectivityConfigurationID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName); err != nil {
		return fmt.Errorf("deleting Network ConnectivityConfiguration (%q): %+v", id, err)
	}
	return nil
}

func expandConnectivityConfigurationConnectivityGroupItemArray(input []interface{}) *[]network.ConnectivityGroupItem {
	results := make([]network.ConnectivityGroupItem, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		useHubGateway := network.UseHubGatewayFalse
		if v["use_hub_gateway"].(bool) {
			useHubGateway = network.UseHubGatewayTrue
		}
		isGlobal := network.IsGlobalFalse
		if v["is_global"].(bool) {
			isGlobal = network.IsGlobalTrue
		}
		results = append(results, network.ConnectivityGroupItem{
			NetworkGroupID:    utils.String(v["network_group_id"].(string)),
			UseHubGateway:     useHubGateway,
			IsGlobal:          isGlobal,
			GroupConnectivity: network.GroupConnectivity(v["group_connectivity"].(string)),
		})
	}
	return &results
}

func flattenConnectivityConfigurationConnectivityGroupItemArray(input *[]network.ConnectivityGroupItem) []interface{} {
	results := make([]interface{}, 0)
	if input == nil {
		return results
	}

	for _, item := range *input {
		var groupConnectivity network.GroupConnectivity
		if item.GroupConnectivity != "" {
			groupConnectivity = item.GroupConnectivity
		}
		isGlobal := item.IsGlobal == network.IsGlobalTrue
		var networkGroupId string
		if item.NetworkGroupID != nil {
			networkGroupId = *item.NetworkGroupID
		}
		useHubGateway := item.UseHubGateway == network.UseHubGatewayTrue
		results = append(results, map[string]interface{}{
			"group_connectivity": groupConnectivity,
			"is_global":          isGlobal,
			"network_group_id":   networkGroupId,
			"use_hub_gateway":    useHubGateway,
		})
	}
	return results
}
