
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034437838876"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220527034437838876"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa4pius"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-220527034437838876"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    operation_name = "Microsoft.Storage/storageAccounts/write"
    category       = "Recommendation"
    resource_id    = azurerm_storage_account.test.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.test.id
  }
}
