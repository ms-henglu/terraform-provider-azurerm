
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011231732540"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1tnce7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_action_group" "test1" {
  name                = "acctestActionGroup1-210924011231732540"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag1"
}

resource "azurerm_monitor_action_group" "test2" {
  name                = "acctestActionGroup2-210924011231732540"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag2"
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-210924011231732540"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_storage_account.test.id]
  enabled             = true
  auto_mitigate       = false
  severity            = 4
  description         = "This is a complete metric alert acceptance."
  frequency           = "PT30M"
  window_size         = "PT12H"

  criteria {
    metric_namespace       = "Microsoft.Storage/storageAccounts"
    metric_name            = "Transactions"
    aggregation            = "Total"
    operator               = "GreaterThan"
    threshold              = 99
    skip_metric_validation = true

    dimension {
      name     = "GeoType"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.test1.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.test2.id
  }
}
