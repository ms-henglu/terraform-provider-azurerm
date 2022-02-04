
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093008436836"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220204093008436836"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
