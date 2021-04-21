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

func resourceNetworkSecurityUserConfiguration() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkSecurityUserConfigurationCreateUpdate,
		Read:   resourceNetworkSecurityUserConfigurationRead,
		Update: resourceNetworkSecurityUserConfigurationCreateUpdate,
		Delete: resourceNetworkSecurityUserConfigurationDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkSecurityUserConfigurationID(id)
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

			"delete_existing_nsgs": {
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
		},
	}
}
func resourceNetworkSecurityUserConfigurationCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.SecurityUserConfigurationClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	networkManagerName := d.Get("network_manager_name").(string)

	id := parse.NewNetworkSecurityUserConfigurationID(subscriptionId, resourceGroup, networkManagerName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network SecurityUserConfiguration (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_security_user_configuration", id.ID())
		}
	}

	deleteExistingNSGs := network.False
	if d.Get("delete_existing_nsgs").(bool) {
		deleteExistingNSGs = network.True
	}
	securityConfiguration := network.SecurityConfiguration{
		SecurityConfigurationPropertiesFormat: &network.SecurityConfigurationPropertiesFormat{
			DeleteExistingNSGs: deleteExistingNSGs,
			Description:        utils.String(d.Get("description").(string)),
			DisplayName:        utils.String(d.Get("display_name").(string)),
			SecurityType:       network.UserPolicy,
		},
	}
	if _, err := client.CreateOrUpdate(ctx, securityConfiguration, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName); err != nil {
		return fmt.Errorf("creating/updating Network SecurityUserConfiguration (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkSecurityUserConfigurationRead(d, meta)
}

func resourceNetworkSecurityUserConfigurationRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.SecurityUserConfigurationClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkSecurityUserConfigurationID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network SecurityUserConfiguration (%q): %+v", id, err)
	}
	d.Set("name", id.SecurityConfigurationName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("network_manager_name", id.NetworkManagerName)
	if props := resp.SecurityConfigurationPropertiesFormat; props != nil {
		d.Set("delete_existing_nsgs", props.DeleteExistingNSGs)
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
	}
	return nil
}

func resourceNetworkSecurityUserConfigurationDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.SecurityUserConfigurationClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkSecurityUserConfigurationID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName); err != nil {
		return fmt.Errorf("deleting Network SecurityUserConfiguration (%q): %+v", id, err)
	}
	return nil
}
