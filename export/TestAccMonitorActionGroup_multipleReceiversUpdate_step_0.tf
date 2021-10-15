
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014525560049"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211015014525560049"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
