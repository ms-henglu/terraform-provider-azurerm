
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061256913883"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test1" {
  name                = "acctestvirtnet-1-240105061256913883"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctestvirtnet-2-240105061256913883"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_network_peering" "test1" {
  name                         = "acctestpeer-1-240105061256913883"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test1.name
  remote_virtual_network_id    = azurerm_virtual_network.test2.id
  allow_virtual_network_access = true
  triggers = {
    remote_address_space = join(",", azurerm_virtual_network.test2.address_space)
  }
}

resource "azurerm_virtual_network_peering" "test2" {
  name                         = "acctestpeer-2-240105061256913883"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test2.name
  remote_virtual_network_id    = azurerm_virtual_network.test1.id
  allow_virtual_network_access = true
  triggers = {
    remote_address_space = join(",", azurerm_virtual_network.test1.address_space)
  }
}
