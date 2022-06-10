
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022554318979"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220610022554318979"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
