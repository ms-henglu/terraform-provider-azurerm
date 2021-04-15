package network

import (
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
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

func resourceNetworkGroup() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkGroupCreateUpdate,
		Read:   resourceNetworkGroupRead,
		Update: resourceNetworkGroupCreateUpdate,
		Delete: resourceNetworkGroupDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkGroupID(id)
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

			"member_type": {
				Type:     schema.TypeString,
				Optional: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.MemberTypeVirtualNetwork),
					string(network.MemberTypeSubnet),
				}, false),
			},

			"conditional_membership": {
				Type:     schema.TypeString,
				Optional: true,
				AtLeastOneOf: []string{"conditional_membership", "group_members"},
				ValidateFunc: validation.StringIsNotWhiteSpace,
			},

			"description": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"display_name": {
				Type:     schema.TypeString,
				Optional: true,
			},

			"group_members": {
				Type:     schema.TypeList,
				Optional: true,
				MinItems: 1,
				AtLeastOneOf: []string{"conditional_membership", "group_members"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"resource_id": {
							Type:     schema.TypeString,
							Required: true,
						},
					},
				},
			},
		},
	}
}
func resourceNetworkGroupCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.GroupClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)

	id := parse.NewNetworkGroupID(subscriptionId, resourceGroup, networkManagerName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network Group (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_group", id.ID())
		}
	}

	parameters := network.Group{
		GroupProperties: &network.GroupProperties{
			ConditionalMembership: utils.String(d.Get("conditional_membership").(string)),
			Description:           utils.String(d.Get("description").(string)),
			DisplayName:           utils.String(d.Get("display_name").(string)),
			GroupMembers:          expandGroupMembersItemArray(d.Get("group_members").([]interface{})),
			MemberType:            network.MemberType(d.Get("member_type").(string)),
		},
	}
	if _, err := client.CreateOrUpdate(ctx, parameters, id.ResourceGroup, id.NetworkManagerName, id.Name, ""); err != nil {
		return fmt.Errorf("creating/updating Network Group (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkGroupRead(d, meta)
}

func resourceNetworkGroupRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.GroupClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkGroupID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network Group (%q): %+v", id, err)
	}
	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("network_manager_name", id.NetworkManagerName)
	if props := resp.GroupProperties; props != nil {
		d.Set("conditional_membership", props.ConditionalMembership)
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
		if err := d.Set("group_members", flattenGroupMembersItemArray(props.GroupMembers)); err != nil {
			return fmt.Errorf("setting `group_members`: %+v", err)
		}
		d.Set("member_type", props.MemberType)
	}
	return nil
}

func resourceNetworkGroupDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.GroupClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkGroupID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.Name); err != nil {
		return fmt.Errorf("deleting Network Group (%q): %+v", id, err)
	}
	return nil
}

func expandGroupMembersItemArray(input []interface{}) *[]network.GroupMembersItem {
	results := make([]network.GroupMembersItem, 0)
	for _, item := range input {
		v := item.(map[string]interface{})
		results = append(results, network.GroupMembersItem{
			ResourceID: utils.String(v["resource_id"].(string)),
		})
	}
	return &results
}

func flattenGroupMembersItemArray(input *[]network.GroupMembersItem) []interface{} {
	results := make([]interface{}, 0)
	if input == nil {
		return results
	}

	for _, item := range *input {
		var resourceId string
		if item.ResourceID != nil {
			resourceId = *item.ResourceID
		}
		results = append(results, map[string]interface{}{
			"resource_id": resourceId,
		})
	}
	return results
}
