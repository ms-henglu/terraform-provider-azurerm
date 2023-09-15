
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023817048309"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230915023817048309"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_action_group" "test2" {
  name                = "acctestActionGroup2-230915023817048309"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag2"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsagq33p"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-230915023817048309"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    operation_name = "Microsoft.Storage/storageAccounts/write"
    category       = "Recommendation"
    resource_id    = azurerm_storage_account.test.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.test2.id
    webhook_properties = {
      from = "terraform test"
      to   = "microsoft azure"
      env  = "test"
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.test.id
    webhook_properties = {
      from = "terraform test"
      env  = "test"
    }
  }
}
