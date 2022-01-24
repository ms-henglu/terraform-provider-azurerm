
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125059573259"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220124125059573259"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
