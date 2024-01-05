
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064223006637"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-240105064223006637"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestsa3jst1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctestsec3jst1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-240105064223006637"
  resource_group_name = azurerm_resource_group.test.name
  enabled             = true
  description         = "This is just a test acceptance."

  scopes = [
    data.azurerm_subscription.current.id,
  ]

  criteria {
    operation_name     = "Microsoft.Storage/storageAccounts/write"
    category           = "Administrative"
    resource_providers = ["Microsoft.Storage", "Microsoft.OperationInsights"]
    resource_types     = ["Microsoft.Storage/storageAccounts", "Microsoft.OperationInsights/workspaces"]
    resource_groups    = [azurerm_resource_group.test.name, azurerm_resource_group.test2.name]
    resource_ids       = [azurerm_storage_account.test.id, azurerm_storage_account.test2.id]
    caller             = "test email address"
    levels             = ["Critical", "Informational"]
    statuses           = ["Succeeded", "Failed"]
    sub_statuses       = ["Succeeded"]
  }
}
