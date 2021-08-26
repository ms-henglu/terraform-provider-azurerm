
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023622367483"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-210826023622367483"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
