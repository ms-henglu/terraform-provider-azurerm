package cognitive

import (
    "encoding/json"
    "fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/cognitiveservices/mgmt/2021-04-30/cognitiveservices"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/cognitive/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/cognitive/validate"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceCognitivePrivateEndpointConnection() *schema.Resource {
	return &schema.Resource{
		Create: resourceCognitivePrivateEndpointConnectionCreateUpdate,
		Read:   resourceCognitivePrivateEndpointConnectionRead,
		Update: resourceCognitivePrivateEndpointConnectionCreateUpdate,
		Delete: resourceCognitivePrivateEndpointConnectionDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.PrivateEndpointConnectionID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"location": azure.SchemaLocation(),

			"account_name": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.CognitiveServicesAccountName(),
			},

			"group_ids": {
				Type:     schema.TypeSet,
				Optional: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},

			"private_link_service_connection_state": {
				Type:     schema.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"actions_required": {
							Type:     schema.TypeString,
							Optional: true,
						},

						"description": {
							Type:     schema.TypeString,
							Optional: true,
						},
					},
				},
			},

			"private_endpoint": {
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"id": {
							Type:     schema.TypeString,
							Computed: true,
						},
					},
				},
			},

			"type": {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}
func resourceCognitivePrivateEndpointConnectionCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Cognitive.PrivateEndpointConnectionsClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	accountName := d.Get("account_name").(string)

	id := parse.NewPrivateEndpointConnectionID(subscriptionId, resourceGroup, accountName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.AccountName, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Cognitive PrivateEndpointConnection (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_cognitive_private_endpoint_connection", id.ID())
		}
	}

	props := cognitiveservices.PrivateEndpointConnection{
		Location: utils.String(location.Normalize(d.Get("location").(string))),
		Properties: &cognitiveservices.PrivateEndpointConnectionProperties{
			GroupIds:                          utils.ExpandStringSlice(d.Get("group_ids").(*schema.Set).List()),
			PrivateLinkServiceConnectionState: expandPrivateEndpointConnectionPrivateLinkServiceConnectionState(d.Get("private_link_service_connection_state").([]interface{})),
		},
	}
	body, _ := json.Marshal(props)
	log.Printf("[INFO] %v", string(body))
	future, err := client.CreateOrUpdate(ctx, id.ResourceGroup, id.AccountName, id.Name, props)
	if err != nil {
		return fmt.Errorf("creating/updating Cognitive PrivateEndpointConnection (%q): %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for creation/update of the Cognitive PrivateEndpointConnection (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceCognitivePrivateEndpointConnectionRead(d, meta)
}

func resourceCognitivePrivateEndpointConnectionRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Cognitive.PrivateEndpointConnectionsClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.PrivateEndpointConnectionID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.AccountName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] cognitiveservices %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Cognitiveservices PrivateEndpointConnection (%q): %+v", id, err)
	}
	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("account_name", id.AccountName)
	d.Set("location", location.NormalizeNilable(resp.Location))
	if props := resp.Properties; props != nil {
		d.Set("group_ids", utils.FlattenStringSlice(props.GroupIds))
		if err := d.Set("private_link_service_connection_state", flattenPrivateEndpointConnectionPrivateLinkServiceConnectionState(props.PrivateLinkServiceConnectionState)); err != nil {
			return fmt.Errorf("setting `private_link_service_connection_state`: %+v", err)
		}
		if err := d.Set("private_endpoint", flattenPrivateEndpointConnectionPrivateEndpoint(props.PrivateEndpoint)); err != nil {
			return fmt.Errorf("setting `private_endpoint`: %+v", err)
		}
	}
	d.Set("type", resp.Type)
	return nil
}

func resourceCognitivePrivateEndpointConnectionDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Cognitive.PrivateEndpointConnectionsClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.PrivateEndpointConnectionID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.Delete(ctx, id.ResourceGroup, id.AccountName, id.Name)
	if err != nil {
		return fmt.Errorf("deleting Cognitiveservices PrivateEndpointConnection (%q): %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for deletion of the Cognitiveservices PrivateEndpointConnection (%q): %+v", id, err)
	}
	return nil
}

func expandPrivateEndpointConnectionPrivateLinkServiceConnectionState(input []interface{}) *cognitiveservices.PrivateLinkServiceConnectionState {
	if len(input) == 0 {
		return nil
	}
	v := input[0].(map[string]interface{})
	return &cognitiveservices.PrivateLinkServiceConnectionState{
		Description:     utils.String(v["description"].(string)),
		ActionsRequired: utils.String(v["actions_required"].(string)),
	}
}

func flattenPrivateEndpointConnectionPrivateLinkServiceConnectionState(input *cognitiveservices.PrivateLinkServiceConnectionState) []interface{} {
	if input == nil {
		return make([]interface{}, 0)
	}

	var actionsRequired string
	if input.ActionsRequired != nil {
		actionsRequired = *input.ActionsRequired
	}
	var description string
	if input.Description != nil {
		description = *input.Description
	}
	return []interface{}{
		map[string]interface{}{
			"actions_required": actionsRequired,
			"description":      description,
		},
	}
}

func flattenPrivateEndpointConnectionPrivateEndpoint(input *cognitiveservices.PrivateEndpoint) []interface{} {
	if input == nil {
		return make([]interface{}, 0)
	}

	var id string
	if input.ID != nil {
		id = *input.ID
	}
	return []interface{}{
		map[string]interface{}{
			"id": id,
		},
	}
}
