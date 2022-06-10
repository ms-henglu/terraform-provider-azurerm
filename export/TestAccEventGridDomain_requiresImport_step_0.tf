
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022554318444"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220610022554318444"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
