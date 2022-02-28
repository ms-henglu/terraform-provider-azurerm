---
subcategory: "Messaging"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_servicebus_namespace_customer_managed_key"
description: |-
  Manages a ServiceBus Namespace Customer Managed Key.
---

# azurerm_servicebus_namespace_customer_managed_key

Manages a ServiceBus Namespace Customer Managed Key.

## Example Usage

```hcl

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "example"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Premium"
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}

resource "azurerm_key_vault" "example" {
  name                     = "example"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  soft_delete_enabled      = true
  purge_protection_enabled = true

  access_policy {
    tenant_id = azurerm_servicebus_namespace.example.identity.0.tenant_id
    object_id = azurerm_servicebus_namespace.example.identity.0.principal_id
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
    tenant_id = azurerm_user_assigned_identity.example.tenant_id
    object_id = azurerm_user_assigned_identity.example.principal_id
    key_permissions = [
      "Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"
    ]
    secret_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = "example"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

resource "azurerm_servicebus_namespace_customer_managed_key" "example" {
  namespace_id                      = azurerm_servicebus_namespace.example.id
  key_vault_key_id                  = azurerm_key_vault_key.example.id
  identity_id                       = azurerm_user_assigned_identity.example.id
  infrastructure_encryption_enabled = true
}
```

## Arguments Reference

The following arguments are supported:

* `namespace_id` - (Required) The ID of the ServiceBus Namespace. Changing this forces a new ServiceBus Namespace Customer Managed Key to be created.

* `key_vault_key_id` - (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this ServiceBus Namespace.

* `identity_id` - (Required) The ID of the User Assigned Identity that has access to the key.

---

* `infrastructure_encryption_enabled` - (Optional) Used to specify whether enable Infrastructure Encryption (Double Encryption).

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the ServiceBus Namespace Customer Managed Key.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the ServiceBus Namespace Customer Managed Key.
* `read` - (Defaults to 5 minutes) Used when retrieving the ServiceBus Namespace Customer Managed Key.
* `update` - (Defaults to 30 minutes) Used when updating the ServiceBus Namespace Customer Managed Key.
* `delete` - (Defaults to 30 minutes) Used when deleting the ServiceBus Namespace Customer Managed Key.

## Import

ServiceBus Namespace Customer Managed Keys can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_servicebus_namespace_customer_managed_key.example /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.ServiceBus/namespaces/namespace1
```
