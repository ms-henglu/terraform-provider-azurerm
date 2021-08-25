

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030013390263"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa4nh2b"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-210825030013390263"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_storage_account.test.id]

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 55.5
  }

  window_size = "PT1H"
}


resource "azurerm_monitor_metric_alert" "import" {
  name                = azurerm_monitor_metric_alert.test.name
  resource_group_name = azurerm_monitor_metric_alert.test.resource_group_name
  scopes              = azurerm_monitor_metric_alert.test.scopes

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 55.5
  }
  window_size = "PT1H"
}
