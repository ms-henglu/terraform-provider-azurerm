package network

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/network/parse"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceNetworkAdminRule() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkAdminRuleCreateUpdate,
		Read:   resourceNetworkAdminRuleRead,
		Update: resourceNetworkAdminRuleCreateUpdate,
		Delete: resourceNetworkAdminRuleDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkAdminRuleID(id)
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

			"access": {
				Type:     schema.TypeString,
				Required: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.SecurityConfigurationRuleAccessAllow),
					string(network.SecurityConfigurationRuleAccessDeny),
					string(network.SecurityConfigurationRuleAccessAlwaysAllow),
				}, false),
			},

			"direction": {
				Type:     schema.TypeString,
				Required: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.SecurityConfigurationRuleDirectionInbound),
					string(network.SecurityConfigurationRuleDirectionOutbound),
				}, false),
			},

			"protocol": {
				Type:     schema.TypeString,
				Required: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.SecurityConfigurationRuleProtocolTCP),
					string(network.SecurityConfigurationRuleProtocolUDP),
					string(network.SecurityConfigurationRuleProtocolIcmp),
					string(network.SecurityConfigurationRuleProtocolEsp),
					string(network.SecurityConfigurationRuleProtocolAny),
					string(network.SecurityConfigurationRuleProtocolAh),
				}, false),
			},

			"applies_to_groups": {
				Type:     schema.TypeList,
				Optional: true,
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

			"destination": {
				Type:     schema.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"address_prefix": {
							Type:     schema.TypeString,
							Required: true,
						},

						"address_prefix_type": {
							Type:     schema.TypeString,
							Required: true,
							ValidateFunc: validation.StringInSlice([]string{
								string(network.IPPrefix),
								string(network.ServiceTag),
							}, false),
						},
					},
				},
			},

			"destination_port_ranges": {
				Type:     schema.TypeList,
				Optional: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},

			"display_name": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"priority": {
				Type:         schema.TypeInt,
				Optional:     true,
				ValidateFunc: validation.IntBetween(1, 4096),
			},

			"source": {
				Type:     schema.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"address_prefix": {
							Type:     schema.TypeString,
							Required: true,
						},

						"address_prefix_type": {
							Type:     schema.TypeString,
							Required: true,
							ValidateFunc: validation.StringInSlice([]string{
								string(network.IPPrefix),
								string(network.ServiceTag),
							}, false),
						},
					},
				},
			},

			"source_port_ranges": {
				Type:     schema.TypeList,
				Optional: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
		},
	}
}
func resourceNetworkAdminRuleCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.AdminRuleClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	configurationName := d.Get("configuration_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)

	id := parse.NewNetworkAdminRuleID(subscriptionId, resourceGroup, networkManagerName, configurationName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.AdminRuleName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network AdminRule (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_admin_rule", id.ID())
		}
	}

	adminRule := network.AdminRule{
		AdminPropertiesFormat: &network.AdminPropertiesFormat{
			Access:                network.SecurityConfigurationRuleAccess(d.Get("access").(string)),
			AppliesToGroups:       expandAdminRuleManagerSecurityGroupItemArray(d.Get("applies_to_groups").([]interface{})),
			Description:           utils.String(d.Get("description").(string)),
			Destination:           expandAdminRuleAddressPrefixItemArray(d.Get("destination").([]interface{})),
			DestinationPortRanges: utils.ExpandStringSlice(d.Get("destination_port_ranges").([]interface{})),
			Direction:             network.SecurityConfigurationRuleDirection(d.Get("direction").(string)),
			DisplayName:           utils.String(d.Get("display_name").(string)),
			Priority:              utils.Int32(int32(d.Get("priority").(int))),
			Protocol:              network.SecurityConfigurationRuleProtocol(d.Get("protocol").(string)),
			Source:                expandAdminRuleAddressPrefixItemArray(d.Get("source").([]interface{})),
			SourcePortRanges:      utils.ExpandStringSlice(d.Get("source_port_ranges").([]interface{})),
		},
	}
	if _, err := client.CreateOrUpdate(ctx, adminRule, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.AdminRuleName); err != nil {
		return fmt.Errorf("creating/updating Network AdminRule (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkAdminRuleRead(d, meta)
}

func resourceNetworkAdminRuleRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.AdminRuleClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkAdminRuleID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.AdminRuleName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network AdminRule (%q): %+v", id, err)
	}
	d.Set("name", id.AdminRuleName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("configuration_name", id.SecurityConfigurationName)
	d.Set("network_manager_name", id.NetworkManagerName)
	if props := resp.AdminPropertiesFormat; props != nil {
		d.Set("access", props.Access)
		d.Set("description", props.Description)
		d.Set("direction", props.Direction)
		d.Set("display_name", props.DisplayName)
		d.Set("priority", props.Priority)
		d.Set("protocol", props.Protocol)
		if err := d.Set("applies_to_groups", flattenAdminRuleManagerSecurityGroupItemArray(props.AppliesToGroups)); err != nil {
			return fmt.Errorf("setting `applies_to_groups`: %+v", err)
		}
		if err := d.Set("source", flattenAdminRuleAddressPrefixItemArray(props.Source)); err != nil {
			return fmt.Errorf("setting `source`: %+v", err)
		}
		if err := d.Set("destination", flattenAdminRuleAddressPrefixItemArray(props.Destination)); err != nil {
			return fmt.Errorf("setting `destination`: %+v", err)
		}
		d.Set("source_port_ranges", utils.FlattenStringSlice(props.SourcePortRanges))
		d.Set("destination_port_ranges", utils.FlattenStringSlice(props.DestinationPortRanges))
	}
	return nil
}

func resourceNetworkAdminRuleDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.AdminRuleClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkAdminRuleID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.AdminRuleName); err != nil {
		return fmt.Errorf("deleting Network AdminRule (%q): %+v", id, err)
	}
	return nil
}

func expandAdminRuleManagerSecurityGroupItemArray(input []interface{}) *[]network.ManagerSecurityGroupItem {
	results := make([]network.ManagerSecurityGroupItem, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		results = append(results, network.ManagerSecurityGroupItem{
			NetworkGroupID: utils.String(v["network_group_id"].(string)),
		})
	}
	return &results
}

func expandAdminRuleAddressPrefixItemArray(input []interface{}) *[]network.AddressPrefixItem {
	results := make([]network.AddressPrefixItem, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		results = append(results, network.AddressPrefixItem{
			AddressPrefix:     utils.String(v["address_prefix"].(string)),
			AddressPrefixType: network.AddressPrefixType(v["address_prefix_type"].(string)),
		})
	}
	return &results
}

func flattenAdminRuleManagerSecurityGroupItemArray(input *[]network.ManagerSecurityGroupItem) []interface{} {
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

func flattenAdminRuleAddressPrefixItemArray(input *[]network.AddressPrefixItem) []interface{} {
	results := make([]interface{}, 0)
	if input == nil {
		return results
	}

	for _, item := range *input {
		var addressPrefix string
		if item.AddressPrefix != nil {
			addressPrefix = *item.AddressPrefix
		}
		var addressPrefixType network.AddressPrefixType
		if item.AddressPrefixType != "" {
			addressPrefixType = item.AddressPrefixType
		}
		results = append(results, map[string]interface{}{
			"address_prefix":      addressPrefix,
			"address_prefix_type": addressPrefixType,
		})
	}
	return results
}
