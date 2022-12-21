
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204636271715"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctestvirtnet221221204636271715"
  address_space           = ["10.0.0.0/16"]
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  flow_timeout_in_minutes = 6
}
