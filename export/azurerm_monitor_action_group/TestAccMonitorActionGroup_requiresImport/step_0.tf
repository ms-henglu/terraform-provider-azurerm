
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034757759861"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230106034757759861"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
