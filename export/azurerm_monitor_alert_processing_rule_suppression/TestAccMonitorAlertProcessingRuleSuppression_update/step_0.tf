

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprs-230512011050432477"
  location = "West Europe"
}


resource "azurerm_monitor_alert_processing_rule_suppression" "test" {
  name                = "acctest-moniter-230512011050432477"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]
}
