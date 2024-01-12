
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034757524133"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa137cxt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_action_group" "test1" {
  name                = "acctestActionGroup1-240112034757524133"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag1"
}

resource "azurerm_monitor_action_group" "test2" {
  name                = "acctestActionGroup2-240112034757524133"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag2"
}

resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-240112034757524133"
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
    webhook_properties = {
      from = "terraform"
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.test2.id
  }

  tags = {
    test          = "456"
    Example       = "Example456"
    Terraform     = "Coolllll"
    tfazurerm     = "Awesome"
    CUSTOMER      = "CUSTOMERx"
    "EXAMPLE.TAG" = "sample"
    "Foo.Bar"     = "Test tag"
  }
}
