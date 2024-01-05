
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064223037205"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa12dj6z"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-240105064223037205"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_storage_account.test.id]

  dynamic_criteria {
    metric_namespace  = "Microsoft.Storage/storageAccounts"
    metric_name       = "Availability"
    aggregation       = "Minimum"
    operator          = "GreaterThan"
    alert_sensitivity = "High"

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }

    evaluation_total_count   = 4
    evaluation_failure_count = 1
  }
}
