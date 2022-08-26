
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002718999595"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220826002718999595"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "foo" = "bar"
  }
}
