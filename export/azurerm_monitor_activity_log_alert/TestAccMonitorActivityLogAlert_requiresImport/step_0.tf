
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040058590757"
  location = "West Europe"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-221202040058590757"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    category = "Recommendation"
  }
}
