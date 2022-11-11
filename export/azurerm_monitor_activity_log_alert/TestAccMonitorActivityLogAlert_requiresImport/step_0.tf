
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013922338523"
  location = "West Europe"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-221111013922338523"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    category = "Recommendation"
  }
}
