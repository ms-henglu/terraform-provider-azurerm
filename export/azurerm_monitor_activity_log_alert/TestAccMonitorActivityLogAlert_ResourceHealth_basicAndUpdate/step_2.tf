
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065312806042"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test1" {
  name                = "acctestActionGroup1-230929065312806042"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag1"
}

resource "azurerm_monitor_action_group" "test2" {
  name                = "acctestActionGroup2-230929065312806042"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag2"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsal62jn"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-230929065312806042"
  resource_group_name = azurerm_resource_group.test.name
  enabled             = true
  description         = "This is just a test acceptance."

  scopes = [
    azurerm_resource_group.test.id,
    azurerm_storage_account.test.id,
  ]

  criteria {
    category                = "ResourceHealth"
    operation_name          = "Microsoft.Storage/storageAccounts/write"
    resource_provider       = "Microsoft.Storage"
    resource_type           = "Microsoft.Storage/storageAccounts"
    resource_group          = azurerm_resource_group.test.name
    resource_id             = azurerm_storage_account.test.id
    recommendation_category = "OperationalExcellence"
    recommendation_impact   = "High"
    level                   = "Critical"
    status                  = "Updated"
    sub_status              = "Updated"
    resource_health {
      current  = ["Degraded", "Unavailable", "Unknown"]
      previous = ["Available"]
      reason   = ["PlatformInitiated", "Unknown"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.test1.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.test2.id

    webhook_properties = {
      from = "terraform test"
      to   = "microsoft azure"
    }
  }
}
