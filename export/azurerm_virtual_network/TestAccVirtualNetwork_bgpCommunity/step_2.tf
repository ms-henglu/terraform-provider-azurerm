
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035101706540"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet221222035101706540"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  bgp_community = "12076:20000"
}
