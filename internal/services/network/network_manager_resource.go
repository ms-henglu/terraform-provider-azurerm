package network

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/validation"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/location"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/network/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tags"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	azSchema "github.com/hashicorp/terraform-provider-azurerm/internal/tf/schema"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceNetworkManager() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkManagerCreate,
		Read:   resourceNetworkManagerRead,
		Delete: resourceNetworkManagerDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkManagerID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"location": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
				//ValidateFunc:     location.EnhancedValidate,
				//StateFunc:        location.StateFunc,
				DiffSuppressFunc: location.DiffSuppressFunc,
			},

			"network_manager_scope_accesses": {
				Type:     schema.TypeList,
				Required: true,
				ForceNew: true,
				MinItems: 1,
				Elem: &schema.Schema{
					Type: schema.TypeString,
					ValidateFunc: validation.StringInSlice([]string{
						string(network.Connectivity),
						string(network.SecurityAdmin),
						string(network.SecurityUser),
					}, false),
				},
			},

			"network_manager_scopes": {
				Type:     schema.TypeList,
				Required: true,
				ForceNew: true,
				MaxItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"management_groups": {
							Type:         schema.TypeList,
							Optional:     true,
							ForceNew:     true,
							MinItems:     1,
							AtLeastOneOf: []string{"network_manager_scopes.0.management_groups", "network_manager_scopes.0.subscriptions"},
							Elem: &schema.Schema{
								Type: schema.TypeString,
							},
						},

						"subscriptions": {
							Type:         schema.TypeList,
							Optional:     true,
							ForceNew:     true,
							MinItems:     1,
							AtLeastOneOf: []string{"network_manager_scopes.0.management_groups", "network_manager_scopes.0.subscriptions"},
							Elem: &schema.Schema{
								Type: schema.TypeString,
							},
						},
					},
				},
			},

			"description": {
				Type:     schema.TypeString,
				Optional: true,
				ForceNew: true,
			},

			"display_name": {
				Type:     schema.TypeString,
				Optional: true,
				ForceNew: true,
			},

			// the api will save and return the tag keys in lowercase, so an extra validation of the key is all in lowercase is added
			"tags": {
				Type:         schema.TypeMap,
				Optional:     true,
				ForceNew:     true,
				ValidateFunc: tags.EnforceLowerCaseKeys,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
		},
	}
}
func resourceNetworkManagerCreate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.ManagerClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)

	id := parse.NewNetworkManagerID(subscriptionId, resourceGroup, name)

	existing, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if !utils.ResponseWasNotFound(existing.Response) {
			return fmt.Errorf("checking for existing Network Manager (%q): %+v", id, err)
		}
	}
	if !utils.ResponseWasNotFound(existing.Response) {
		return tf.ImportAsExistsError("azurerm_network_manager", id.ID())
	}

	networkManagerScopeAccesses := make([]network.ConfigurationType, 0)
	for _, item := range *(utils.ExpandStringSlice(d.Get("network_manager_scope_accesses").([]interface{}))) {
		networkManagerScopeAccesses = append(networkManagerScopeAccesses, (network.ConfigurationType)(item))
	}

	parameters := network.Manager{
		Location: utils.String(location.Normalize(d.Get("location").(string))),
		ManagerProperties: &network.ManagerProperties{
			Description:                 utils.String(d.Get("description").(string)),
			DisplayName:                 utils.String(d.Get("display_name").(string)),
			NetworkManagerScopeAccesses: &networkManagerScopeAccesses,
			NetworkManagerScopes:        expandNetworkManagerPropertiesNetworkManagerScopes(d.Get("network_manager_scopes").([]interface{})),
		},
		Tags: tags.Expand(d.Get("tags").(map[string]interface{})),
	}

	j, _ := json.Marshal(parameters)
	log.Printf("[INFO] body: %v", string(j))
	if _, err := client.CreateOrUpdate(ctx, parameters, id.ResourceGroup, id.Name); err != nil {
		return fmt.Errorf("error creating/updating Network Manager (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkManagerRead(d, meta)
}

func resourceNetworkManagerRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.ManagerClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkManagerID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network Manager (%q): %+v", id, err)
	}
	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("location", location.NormalizeNilable(resp.Location))
	if props := resp.ManagerProperties; props != nil {
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
		networkManagerScopeAccesses := make([]string, 0)
		if props.NetworkManagerScopeAccesses != nil {
			for _, item := range *props.NetworkManagerScopeAccesses {
				networkManagerScopeAccesses = append(networkManagerScopeAccesses, (string)(item))
			}
		}
		d.Set("network_manager_scope_accesses", utils.FlattenStringSlice(&networkManagerScopeAccesses))
		if err := d.Set("network_manager_scopes", flattenNetworkManagerPropertiesNetworkManagerScopes(props.NetworkManagerScopes)); err != nil {
			return fmt.Errorf("setting `network_manager_scopes`: %+v", err)
		}
	}
	return tags.FlattenAndSet(d, resp.Tags)
}

func resourceNetworkManagerDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.ManagerClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkManagerID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.Name); err != nil {
		return fmt.Errorf("deleting Network Manager (%q): %+v", id, err)
	}
	return nil
}

func expandNetworkManagerPropertiesNetworkManagerScopes(input []interface{}) *network.ManagerPropertiesNetworkManagerScopes {
	if len(input) == 0 {
		return nil
	}
	v := input[0].(map[string]interface{})
	return &network.ManagerPropertiesNetworkManagerScopes{
		ManagementGroups: utils.ExpandStringSlice(v["management_groups"].([]interface{})),
		Subscriptions:    utils.ExpandStringSlice(v["subscriptions"].([]interface{})),
	}
}

func flattenNetworkManagerPropertiesNetworkManagerScopes(input *network.ManagerPropertiesNetworkManagerScopes) []interface{} {
	if input == nil {
		return make([]interface{}, 0)
	}

	return []interface{}{
		map[string]interface{}{
			"management_groups": utils.FlattenStringSlice(input.ManagementGroups),
			"subscriptions":     utils.FlattenStringSlice(input.Subscriptions),
		},
	}
}
