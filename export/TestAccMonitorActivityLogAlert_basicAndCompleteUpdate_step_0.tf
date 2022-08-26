
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003031539996"
  location = "West Europe"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-220826003031539996"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    category = "Recommendation"
  }
}
