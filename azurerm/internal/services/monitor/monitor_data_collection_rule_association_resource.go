package monitor

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/monitor/mgmt/2021-04-01-preview/insights"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	computeParse "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/compute/parse"
	computeValidate "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/compute/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceMonitorDataCollectionRuleAssociation() *schema.Resource {
	return &schema.Resource{
		Create: resourceMonitorDataCollectionRuleAssociationCreateUpdate,
		Read:   resourceMonitorDataCollectionRuleAssociationRead,
		Update: resourceMonitorDataCollectionRuleAssociationCreateUpdate,
		Delete: resourceMonitorDataCollectionRuleAssociationDelete,
		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.DataCollectionRuleAssociationID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"virtual_machine_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: computeValidate.VirtualMachineID,
			},

			"data_collection_endpoint_id": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				ValidateFunc: validate.DataCollectionEndpointID,
				ExactlyOneOf: []string{"data_collection_endpoint_id", "data_collection_rule_id"},
			},

			"data_collection_rule_id": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				ValidateFunc: validate.DataCollectionRuleID,
				ExactlyOneOf: []string{"data_collection_endpoint_id", "data_collection_rule_id"},
			},

			"description": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},
		},
	}
}

func resourceMonitorDataCollectionRuleAssociationCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Monitor.DataCollectionRuleAssociationsClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	vmResourceUri := d.Get("virtual_machine_id").(string)
	vmId, _ := computeParse.VirtualMachineID(vmResourceUri)

	id := parse.NewDataCollectionRuleAssociationID(subscriptionId, vmId.ResourceGroup, vmId.Name, name)
	if d.IsNewResource() {
		existing, err := client.Get(ctx, vmResourceUri, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Monitor DataCollectionRuleAssociation %q: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_monitor_data_collection_rule_association", id.ID())
		}

	}

	props := insights.DataCollectionRuleAssociationProxyOnlyResourceProperties{}
	if endpointId, ok := d.GetOk("data_collection_endpoint_id"); ok {
		props.DataCollectionEndpointID = utils.String(endpointId.(string))
	}
	if ruleId, ok := d.GetOk("data_collection_rule_id"); ok {
		props.DataCollectionRuleID = utils.String(ruleId.(string))
	}
	if description, ok := d.GetOk("description"); ok {
		props.Description = utils.String(description.(string))
	}
	body := insights.DataCollectionRuleAssociationProxyOnlyResource{
		DataCollectionRuleAssociationProxyOnlyResourceProperties: &props,
	}
	_, err := client.Create(ctx, vmResourceUri, id.Name, &body)
	if err != nil {
		return fmt.Errorf("creating Monitor DataCollectionRuleAssociation %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceMonitorDataCollectionRuleAssociationRead(d, meta)
}

func resourceMonitorDataCollectionRuleAssociationRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionRuleAssociationsClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionRuleAssociationID(d.Id())
	if err != nil {
		return err
	}

	vmId := computeParse.NewVirtualMachineID(id.SubscriptionId, id.ResourceGroup, id.VirtualMachineName)
	resp, err := client.Get(ctx, vmId.ID(), id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] Monitor DataCollectionRuleAssociation %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Monitor DataCollectionRuleAssociation %q: %+v", id, err)
	}

	d.Set("name", id.Name)
	d.Set("virtual_machine_id", vmId.ID())
	if resp.Description != nil {
		d.Set("description", *resp.Description)
	}
	if props := resp.DataCollectionRuleAssociationProxyOnlyResourceProperties; props != nil {
		d.Set("data_collection_endpoint_id", props.DataCollectionEndpointID)
		d.Set("data_collection_rule_id", props.DataCollectionRuleID)
	}

	return nil
}

func resourceMonitorDataCollectionRuleAssociationDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionRuleAssociationsClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionRuleAssociationID(d.Id())
	if err != nil {
		return err
	}
	vmId := computeParse.NewVirtualMachineID(id.SubscriptionId, id.ResourceGroup, id.VirtualMachineName)
	_, err = client.Delete(ctx, vmId.ID(), id.Name)
	if err != nil {
		return fmt.Errorf("deleting Monitor DataCollectionRuleAssociation %q: %+v", id, err)
	}

	return nil
}
