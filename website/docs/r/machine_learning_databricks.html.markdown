---
subcategory: "Machine Learning"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_machine_learning_databricks"
description: |-
  Manages a Machine Learning Databricks.
---

# azurerm_machine_learning_databricks

Manages a Machine Learning Databricks.

## Example Usage

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "west europe"
  tags = {
    "stage" = "example"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "example-ai"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_key_vault" "example" {
  name                = "example-kv"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "example" {
  name                     = "examplesa"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_machine_learning_workspace" "example" {
  name                    = "example-mlw"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  application_insights_id = azurerm_application_insights.example.id
  key_vault_id            = azurerm_key_vault.example.id
  storage_account_id      = azurerm_storage_account.example.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_databricks_workspace" "example" {
  name                = "example-databricks"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_machine_learning_databricks" "example" {
  name                          = "example"
  location                      = azurerm_resource_group.example.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.example.id
  databricks_workspace_id       = azurerm_databricks_workspace.example.id
  databricks_access_token       = "dapi1234567890ab1cde2f3ab456c7d89efa"

  identity {
    type = "SystemAssigned"
  }
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this Machine Learning Databricks. Changing this forces a new Machine Learning Databricks to be created.

* `machine_learning_workspace_id` - (Required) The ID of the TODO. Changing this forces a new Machine Learning Databricks to be created.

* `location` - (Required) The Azure Region where the Machine Learning Databricks should exist. Changing this forces a new Machine Learning Databricks to be created.
  
* `databricks_access_token` - (Required) The Databricks access token.

* `databricks_workspace_id` - (Required) The ID of the Databricks. Changing this forces a new Machine Learning Databricks to be created.

---

* `description` - (Optional) The description of the Machine Learning Databricks. Changing this forces a new Machine Learning Databricks to be created.

* `identity` - (Optional) A `identity` block as defined below.

* `tags` - (Optional) A mapping of tags which should be assigned to the Machine Learning Databricks. Changing this forces a new Machine Learning Databricks to be created.

---

A `identity` block supports the following:

* `type` - (Required) Specifies the type of Managed Service Identity that should be configured on the Machine Learning Databricks. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned,UserAssigned` (to enable both).

* `identity_ids` - (Optional) A list of IDs for User Assigned Managed Identity resources to be assigned.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the Machine Learning Databricks.

* `identity` - An `identity` block as defined below, which contains the Managed Service Identity information for this Machine Learning Databricks.

---

The `identity` block exports the following:

* `principal_id` - The Principal ID for the Service Principal associated with the Managed Service Identity of this Machine Learning Databricks.

* `tenant_id` - The Tenant ID for the Service Principal associated with the Managed Service Identity of this Machine Learning Databricks.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the Machine Learning Databricks.
* `read` - (Defaults to 5 minutes) Used when retrieving the Machine Learning Databricks.
* `delete` - (Defaults to 30 minutes) Used when deleting the Machine Learning Databricks.

## Import

Machine Learning Databrickss can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_machine_learning_databricks.example C:/Program Files/Git/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resGroup1/providers/Microsoft.MachineLearningServices/workspaces/workspace1/computes/compute1
```
