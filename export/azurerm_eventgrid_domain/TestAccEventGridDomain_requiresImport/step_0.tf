
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021031207031914"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-221021031207031914"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
