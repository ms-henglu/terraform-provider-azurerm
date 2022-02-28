package servicebus_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/check"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/servicebus/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

type ServiceBusNamespaceCustomerManagedKeyResource struct{}

func TestAccServiceBusNamespaceCustomerManagedKey_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_servicebus_namespace_customer_managed_key", "test")
	r := ServiceBusNamespaceCustomerManagedKeyResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccServiceBusNamespaceCustomerManagedKey_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_servicebus_namespace_customer_managed_key", "test")
	r := ServiceBusNamespaceCustomerManagedKeyResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func TestAccServiceBusNamespaceCustomerManagedKey_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_servicebus_namespace_customer_managed_key", "test")
	r := ServiceBusNamespaceCustomerManagedKeyResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func (r ServiceBusNamespaceCustomerManagedKeyResource) Exists(ctx context.Context, clients *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := parse.NamespaceID(state.ID)
	if err != nil {
		return nil, err
	}

	resp, err := clients.ServiceBus.NamespacesClient.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return nil, fmt.Errorf("retrieving %s: %v", *id, err)
	}

	if resp.SBNamespaceProperties == nil || resp.SBNamespaceProperties.Encryption == nil {
		return utils.Bool(false), nil
	}

	return utils.Bool(true), nil
}

func (r ServiceBusNamespaceCustomerManagedKeyResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s
resource "azurerm_servicebus_namespace_customer_managed_key" "test" {
  namespace_id     = azurerm_servicebus_namespace.test.id
  key_vault_key_id = azurerm_key_vault_key.test.id
  identity_id      = azurerm_user_assigned_identity.test.id
}
`, r.template(data))
}

func (r ServiceBusNamespaceCustomerManagedKeyResource) requiresImport(data acceptance.TestData) string {
	template := r.basic(data)
	return fmt.Sprintf(`
%s
resource "azurerm_servicebus_namespace_customer_managed_key" "import" {
  namespace_id     = azurerm_servicebus_namespace_customer_managed_key.test.namespace_id
  key_vault_key_id = azurerm_servicebus_namespace_customer_managed_key.test.key_vault_key_id
  identity_id      = azurerm_servicebus_namespace_customer_managed_key.test.identity_id
}
`, template)
}

func (r ServiceBusNamespaceCustomerManagedKeyResource) complete(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s
resource "azurerm_servicebus_namespace_customer_managed_key" "test" {
  namespace_id                      = azurerm_servicebus_namespace.test.id
  key_vault_key_id                  = azurerm_key_vault_key.test.id
  identity_id                       = azurerm_user_assigned_identity.test.id
  infrastructure_encryption_enabled = true
}
`, r.template(data))
}

func (r ServiceBusNamespaceCustomerManagedKeyResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-servicebus-%[3]d"
  location = "%[1]s"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "%[2]s"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-sb-%[3]d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
  capacity            = 1
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkv%[2]s"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true

  access_policy {
    tenant_id = azurerm_servicebus_namespace.test.identity.0.tenant_id
    object_id = azurerm_servicebus_namespace.test.identity.0.principal_id
    key_permissions = [
      "Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"
    ]
    secret_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"
    ]
    secret_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.test.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id
    key_permissions = [
      "Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"
    ]
    secret_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkey%[2]s"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}
`, data.Locations.Primary, data.RandomString, data.RandomInteger)
}
