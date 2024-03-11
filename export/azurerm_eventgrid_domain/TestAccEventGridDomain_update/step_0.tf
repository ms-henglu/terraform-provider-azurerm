
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032056386322"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-240311032056386322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
