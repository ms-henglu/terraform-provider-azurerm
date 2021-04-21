package network

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/network/parse"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceNetworkAdminRuleCollection() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkAdminRuleCollectionCreateUpdate,
		Read:   resourceNetworkAdminRuleCollectionRead,
		Update: resourceNetworkAdminRuleCollectionCreateUpdate,
		Delete: resourceNetworkAdminRuleCollectionDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkAdminRuleCollectionID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"configuration_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

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
					},
				},
			},

			"description": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"display_name": {
				Type:     schema.TypeString,
				Optional: true,
			},
		},
	}
}
func resourceNetworkAdminRuleCollectionCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.AdminRuleCollectionClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)
	configurationName := d.Get("configuration_name").(string)

	id := parse.NewNetworkAdminRuleCollectionID(subscriptionId, resourceGroup, networkManagerName, configurationName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network AdminRuleCollection (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_admin_rule_collection", id.ID())
		}
	}

	ruleCollection := network.RuleCollection{
		RuleCollectionPropertiesFormat: &network.RuleCollectionPropertiesFormat{
			Description:     utils.String(d.Get("description").(string)),
			DisplayName:     utils.String(d.Get("display_name").(string)),
			AppliesToGroups: expandManagerSecurityGroupItemArray(d.Get("applies_to_groups").(*schema.Set).List()),
		},
	}
	if _, err := client.CreateOrUpdate(ctx, ruleCollection, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName); err != nil {
		return fmt.Errorf("creating/updating Network AdminRuleCollection (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkAdminRuleCollectionRead(d, meta)
}

func resourceNetworkAdminRuleCollectionRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.AdminRuleCollectionClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkAdminRuleCollectionID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] Network AdminRuleCollection %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network AdminRuleCollection (%q): %+v", id, err)
	}
	d.Set("name", id.RuleCollectionName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("network_manager_name", id.NetworkManagerName)
	d.Set("configuration_name", id.SecurityConfigurationName)
	if props := resp.RuleCollectionPropertiesFormat; props != nil {
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
		d.Set("applies_to_groups", flattenManagerSecurityGroupItemArray(props.AppliesToGroups))
	}
	return nil
}

func resourceNetworkAdminRuleCollectionDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.AdminRuleCollectionClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkAdminRuleCollectionID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName); err != nil {
		return fmt.Errorf("deleting Network AdminRuleCollection (%q): %+v", id, err)
	}
	return nil
}

func expandManagerSecurityGroupItemArray(input []interface{}) *[]network.ManagerSecurityGroupItem {
	results := make([]network.ManagerSecurityGroupItem, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		results = append(results, network.ManagerSecurityGroupItem{
			NetworkGroupID: utils.String(v["network_group_id"].(string)),
		})
	}
	return &results
}

func flattenManagerSecurityGroupItemArray(input *[]network.ManagerSecurityGroupItem) []interface{} {
	results := make([]interface{}, 0)
	if input == nil {
		return results
	}

	for _, item := range *input {
		var networkGroupId string
		if item.NetworkGroupID != nil {
			networkGroupId = *item.NetworkGroupID
		}
		results = append(results, map[string]interface{}{
			"network_group_id": networkGroupId,
		})
	}
	return results
}
