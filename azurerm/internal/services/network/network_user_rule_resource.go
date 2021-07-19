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

func resourceNetworkUserRule() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkUserRuleCreateUpdate,
		Read:   resourceNetworkUserRuleRead,
		Update: resourceNetworkUserRuleCreateUpdate,
		Delete: resourceNetworkUserRuleDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkUserRuleID(id)
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

			"rule_collection_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
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

			"description": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"destinations": {
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

			"sources": {
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
func resourceNetworkUserRuleCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.UserRuleClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	configurationName := d.Get("configuration_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)
	ruleCollectionName := d.Get("rule_collection_name").(string)

	id := parse.NewNetworkUserRuleID(subscriptionId, resourceGroup, networkManagerName, configurationName, ruleCollectionName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network UserRule (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_user_rule", id.ID())
		}
	}

	userRule := network.UserRule{
		UserRulePropertiesFormat: &network.UserRulePropertiesFormat{
			Description:           utils.String(d.Get("description").(string)),
			Destinations:          expandUserRuleAddressPrefixItemArray(d.Get("destinations").([]interface{})),
			DestinationPortRanges: utils.ExpandStringSlice(d.Get("destination_port_ranges").([]interface{})),
			Direction:             network.SecurityConfigurationRuleDirection(d.Get("direction").(string)),
			DisplayName:           utils.String(d.Get("display_name").(string)),
			Protocol:              network.SecurityConfigurationRuleProtocol(d.Get("protocol").(string)),
			Sources:               expandUserRuleAddressPrefixItemArray(d.Get("sources").([]interface{})),
			SourcePortRanges:      utils.ExpandStringSlice(d.Get("source_port_ranges").([]interface{})),
		},
	}
	if _, err := client.CreateOrUpdate(ctx, userRule, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName); err != nil {
		return fmt.Errorf("creating/updating Network UserRule (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkUserRuleRead(d, meta)
}

func resourceNetworkUserRuleRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.UserRuleClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkUserRuleID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network UserRule (%q): %+v", id, err)
	}
	d.Set("name", id.RuleName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("configuration_name", id.SecurityConfigurationName)
	d.Set("network_manager_name", id.NetworkManagerName)
	d.Set("rule_collection_name", id.RuleCollectionName)
	if userRule, ok := resp.Value.AsUserRule(); ok {
		if props := userRule.UserRulePropertiesFormat; props != nil {
			d.Set("description", props.Description)
			d.Set("direction", props.Direction)
			d.Set("display_name", props.DisplayName)
			d.Set("protocol", props.Protocol)
			if err := d.Set("sources", flattenUserRuleAddressPrefixItemArray(props.Sources)); err != nil {
				return fmt.Errorf("setting `source`: %+v", err)
			}
			if err := d.Set("destinations", flattenUserRuleAddressPrefixItemArray(props.Destinations)); err != nil {
				return fmt.Errorf("setting `destination`: %+v", err)
			}
			d.Set("source_port_ranges", utils.FlattenStringSlice(props.SourcePortRanges))
			d.Set("destination_port_ranges", utils.FlattenStringSlice(props.DestinationPortRanges))
		}
	}
	return nil
}

func resourceNetworkUserRuleDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.UserRuleClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkUserRuleID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName); err != nil {
		return fmt.Errorf("deleting Network UserRule (%q): %+v", id, err)
	}
	return nil
}

func expandUserRuleAddressPrefixItemArray(input []interface{}) *[]network.AddressPrefixItem {
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

func flattenUserRuleAddressPrefixItemArray(input *[]network.AddressPrefixItem) []interface{} {
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
