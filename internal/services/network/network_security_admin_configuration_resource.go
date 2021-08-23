package network

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/validation"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/network/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/network/validate"
	azSchema "github.com/hashicorp/terraform-provider-azurerm/internal/tf/schema"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceNetworkSecurityAdminConfiguration() *schema.Resource {
	return &schema.Resource{
		Create: resourceNetworkSecurityAdminConfigurationCreateUpdate,
		Read:   resourceNetworkSecurityAdminConfigurationRead,
		Update: resourceNetworkSecurityAdminConfigurationCreateUpdate,
		Delete: resourceNetworkSecurityAdminConfigurationDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.NetworkSecurityAdminConfigurationID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"network_manager_id": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.NetworkManagerID,
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

			"security_type": {
				Type:     schema.TypeString,
				Optional: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(network.AdminPolicy),
					string(network.UserPolicy),
				}, false),
			},
		},
	}
}
func resourceNetworkSecurityAdminConfigurationCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Network.SecurityAdminConfigurationClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	managerId, _ := parse.NetworkManagerID(d.Get("network_manager_id").(string))

	id := parse.NewNetworkSecurityAdminConfigurationID(subscriptionId, managerId.ResourceGroup, managerId.Name, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityAdminConfigurationName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Network SecurityAdminConfiguration (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_network_security_admin_configuration", id.ID())
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
			SecurityType:       network.SecurityType(d.Get("security_type").(string)),
		},
	}
	if _, err := client.CreateOrUpdate(ctx, securityConfiguration, id.ResourceGroup, id.NetworkManagerName, id.SecurityAdminConfigurationName); err != nil {
		return fmt.Errorf("creating/updating Network SecurityAdminConfiguration (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceNetworkSecurityAdminConfigurationRead(d, meta)
}

func resourceNetworkSecurityAdminConfigurationRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.SecurityAdminConfigurationClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkSecurityAdminConfigurationID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityAdminConfigurationName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] network %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Network SecurityAdminConfiguration (%q): %+v", id, err)
	}
	d.Set("name", id.SecurityAdminConfigurationName)
	d.Set("network_manager_id", parse.NewNetworkManagerID(id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName).ID())
	if props := resp.SecurityConfigurationPropertiesFormat; props != nil {
		d.Set("delete_existing_nsgs", strings.EqualFold(string(props.DeleteExistingNSGs), string(network.True)))
		d.Set("description", props.Description)
		d.Set("display_name", props.DisplayName)
		d.Set("security_type", props.SecurityType)
	}
	return nil
}

func resourceNetworkSecurityAdminConfigurationDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Network.SecurityAdminConfigurationClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NetworkSecurityAdminConfigurationID(d.Id())
	if err != nil {
		return err
	}

	if _, err := client.Delete(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityAdminConfigurationName); err != nil {
		return fmt.Errorf("deleting Network SecurityAdminConfiguration (%q): %+v", id, err)
	}
	return nil
}
