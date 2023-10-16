

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprs-231016034326091931"
  location = "West Europe"
}


resource "azurerm_monitor_alert_processing_rule_suppression" "test" {
  name                = "acctest-moniter-231016034326091931"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]
}
