
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060759128366"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-240105060759128366"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
