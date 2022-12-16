
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013859234813"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221216013859234813"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
