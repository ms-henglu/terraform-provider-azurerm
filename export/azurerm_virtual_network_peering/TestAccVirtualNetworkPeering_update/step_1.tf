
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034901675886"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test1" {
  name                = "acctestvirtnet-1-240112034901675886"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctestvirtnet-2-240112034901675886"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_network_peering" "test1" {
  name                         = "acctestpeer-1-240112034901675886"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test1.name
  remote_virtual_network_id    = azurerm_virtual_network.test2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "test2" {
  name                         = "acctestpeer-2-240112034901675886"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test2.name
  remote_virtual_network_id    = azurerm_virtual_network.test1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}
