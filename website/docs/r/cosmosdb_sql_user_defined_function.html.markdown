---
subcategory: "CosmosDB (DocumentDB)"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_cosmosdb_sql_user_defined_function"
description: |-
  Manages an SQL User Defined Function.
---

# azurerm_cosmosdb_sql_user_defined_function

Manages an SQL User Defined Function.

## Example Usage

```hcl
data "azurerm_cosmosdb_account" "example" {
  name                = "tfex-cosmosdb-account"
  resource_group_name = "tfex-cosmosdb-account-rg"
}

resource "azurerm_cosmosdb_sql_database" "example" {
  name                = "tfex-cosmos-db"
  resource_group_name = data.azurerm_cosmosdb_account.example.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.example.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "example" {
  name                = "example-container"
  resource_group_name = azurerm_cosmosdb_account.example.resource_group_name
  account_name        = azurerm_cosmosdb_account.example.name
  database_name       = azurerm_cosmosdb_sql_database.example.name
  partition_key_path  = "/id"
}

resource "azurerm_cosmosdb_sql_user_defined_function" "example" {
  name                = "test-function"
  resource_group_name = azurerm_cosmosdb_account.example.resource_group_name
  account_name        = azurerm_cosmosdb_account.example.name
  database_name       = azurerm_cosmosdb_sql_database.example.name
  container_name      = azurerm_cosmosdb_sql_container.example.name
  body                = "function trigger(){}"
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this SQL User Defined Function. Changing this forces a new SQL User Defined Function to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the SQL User Defined Function should exist. Changing this forces a new SQL User Defined Function to be created.

* `account_name` - (Required) The name of the Cosmos DB Account to create the SQL User Defined Function within. Changing this forces a new SQL User Defined Function to be created.

* `container_name` - (Required) The name of the Cosmos DB SQL Container to create the SQL User Defined Function within. Changing this forces a new SQL User Defined Function to be created.

* `database_name` - (Required) The name of the Cosmos DB SQL Database to create the SQL User Defined Function within. Changing this forces a new SQL User Defined Function to be created.

* `body` - (Required) Body of the User Defined Function.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the SQL User Defined Function.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the SQL User Defined Function.
* `read` - (Defaults to 5 minutes) Used when retrieving the SQL User Defined Function.
* `update` - (Defaults to 30 minutes) Used when updating the SQL User Defined Function.
* `delete` - (Defaults to 30 minutes) Used when deleting the SQL User Defined Function.

## Import

SQL User Defined Functions can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_cosmosdb_sql_user_defined_function.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.DocumentDB/databaseAccounts/account1/sqlDatabases/database1/containers/container1/userDefinedFunctions/userDefinedFunction1
```
