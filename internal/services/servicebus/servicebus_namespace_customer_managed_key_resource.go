package servicebus

import (
	"fmt"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/servicebus/mgmt/2021-06-01-preview/servicebus"
	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/locks"
	keyVaultParse "github.com/hashicorp/terraform-provider-azurerm/internal/services/keyvault/parse"
	keyVaultValidate "github.com/hashicorp/terraform-provider-azurerm/internal/services/keyvault/validate"
	msiValidate "github.com/hashicorp/terraform-provider-azurerm/internal/services/msi/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/servicebus/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/servicebus/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceServiceBusNamespaceCustomerManagedKey() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceServiceBusNamespaceCustomerManagedKeyCreateUpdate,
		Read:   resourceServiceBusNamespaceCustomerManagedKeyRead,
		Update: resourceServiceBusNamespaceCustomerManagedKeyCreateUpdate,
		Delete: resourceServiceBusNamespaceCustomerManagedKeyDelete,

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Importer: pluginsdk.DefaultImporter(),

		Schema: map[string]*pluginsdk.Schema{
			"namespace_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.NamespaceID,
			},

			"key_vault_key_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: keyVaultValidate.NestedItemIdWithOptionalVersion,
			},

			"identity_id": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				ValidateFunc: msiValidate.UserAssignedIdentityID,
			},

			"infrastructure_encryption_enabled": {
				Type:     pluginsdk.TypeBool,
				Optional: true,
			},
		},
	}
}

func resourceServiceBusNamespaceCustomerManagedKeyCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).ServiceBus.NamespacesClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NamespaceID(d.Get("namespace_id").(string))
	if err != nil {
		return err
	}

	locks.ByName(id.Name, "azurerm_servicebus_namespace")
	defer locks.UnlockByName(id.Name, "azurerm_servicebus_namespace")

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return fmt.Errorf("retrieving %s: %+v", id, err)
	}

	if d.IsNewResource() {
		if resp.SBNamespaceProperties != nil && resp.SBNamespaceProperties.Encryption != nil {
			return tf.ImportAsExistsError("azurerm_servicebus_namespace_customer_managed_key", id.ID())
		}
	}

	keyId, err := keyVaultParse.ParseOptionallyVersionedNestedItemID(d.Get("key_vault_key_id").(string))
	if err != nil {
		return err
	}
	props := resp
	props.SBNamespaceProperties.Encryption = &servicebus.Encryption{
		KeyVaultProperties: &[]servicebus.KeyVaultProperties{
			{
				KeyName:     utils.String(keyId.Name),
				KeyVersion:  utils.String(keyId.Version),
				KeyVaultURI: utils.String(keyId.KeyVaultBaseUrl),
				Identity: &servicebus.UserAssignedIdentityProperties{
					UserAssignedIdentity: utils.String(d.Get("identity_id").(string)),
				},
			},
		},
		KeySource:                       servicebus.KeySourceMicrosoftKeyVault,
		RequireInfrastructureEncryption: utils.Bool(d.Get("infrastructure_encryption_enabled").(bool)),
	}

	if _, err = client.CreateOrUpdate(ctx, id.ResourceGroup, id.Name, props); err != nil {
		return fmt.Errorf("adding Customer Managed Key for %s: %+v", id, err)
	}

	d.SetId(id.ID())

	return resourceServiceBusNamespaceCustomerManagedKeyRead(d, meta)
}

func resourceServiceBusNamespaceCustomerManagedKeyRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).ServiceBus.NamespacesClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NamespaceID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return fmt.Errorf("retrieving %s: %+v", *id, err)
	}
	if resp.SBNamespaceProperties == nil || resp.SBNamespaceProperties.Encryption == nil {
		d.SetId("")
		return nil
	}

	d.Set("namespace_id", id.ID())
	d.Set("infrastructure_encryption_enabled", resp.SBNamespaceProperties.Encryption.RequireInfrastructureEncryption)
	if keyVaultProperties := resp.SBNamespaceProperties.Encryption.KeyVaultProperties; keyVaultProperties != nil && len(*keyVaultProperties) != 0 {
		props := (*keyVaultProperties)[0]
		keyVaultKeyId, err := keyVaultParse.NewNestedItemID(*props.KeyVaultURI, "keys", *props.KeyName, *props.KeyVersion)
		if err != nil {
			return fmt.Errorf("parsing `key_vault_key_id`: %+v", err)
		}
		d.Set("key_vault_key_id", keyVaultKeyId.ID())
		if props.Identity != nil {
			d.Set("identity_id", props.Identity.UserAssignedIdentity)
		}
	}

	return nil
}

func resourceServiceBusNamespaceCustomerManagedKeyDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).ServiceBus.NamespacesClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.NamespaceID(d.Id())
	if err != nil {
		return err
	}

	locks.ByName(id.Name, "azurerm_servicebus_namespace")
	defer locks.UnlockByName(id.Name, "azurerm_servicebus_namespace")

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return nil
		}
		return fmt.Errorf("retrieving %s: %+v", *id, err)
	}

	// Since this isn't a real object and it cannot be disabled once Customer Managed Key at rest has been enabled
	// And it must keep at least one key once Customer Managed Key is enabled
	// So for the delete operation, it has to recreate the EventHub Namespace with disabled Customer Managed Key
	deleteFuture, err := client.Delete(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return fmt.Errorf("deleting %s: %+v", *id, err)
	}
	if err = deleteFuture.WaitForCompletionRef(ctx, client.Client); err != nil {
		if !response.WasNotFound(deleteFuture.Response()) {
			return fmt.Errorf("failed to wait for removal of %q: %+v", id, err)
		}
	}

	namespace := resp
	namespace.Encryption = nil

	future, err := client.CreateOrUpdate(ctx, id.ResourceGroup, id.Name, namespace)
	if err != nil {
		return fmt.Errorf("creating/updating %s: %+v", id, err)
	}

	if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for create/update of %s: %+v", id, err)
	}

	return nil
}
