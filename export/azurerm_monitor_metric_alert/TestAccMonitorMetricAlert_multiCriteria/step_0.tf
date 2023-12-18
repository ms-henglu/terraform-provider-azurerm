
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072152369476"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1gnuam"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-231218072152369476"
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
      values   = ["Primary"]
    }
  }

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 55.5
  }

}
