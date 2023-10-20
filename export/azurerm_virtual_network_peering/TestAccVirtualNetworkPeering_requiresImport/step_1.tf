

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041557356660"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test1" {
  name                = "acctestvirtnet-1-231020041557356660"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctestvirtnet-2-231020041557356660"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_network_peering" "test1" {
  name                         = "acctestpeer-1-231020041557356660"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test1.name
  remote_virtual_network_id    = azurerm_virtual_network.test2.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "test2" {
  name                         = "acctestpeer-2-231020041557356660"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test2.name
  remote_virtual_network_id    = azurerm_virtual_network.test1.id
  allow_virtual_network_access = true
}


resource "azurerm_virtual_network_peering" "import" {
  name                         = azurerm_virtual_network_peering.test1.name
  resource_group_name          = azurerm_virtual_network_peering.test1.resource_group_name
  virtual_network_name         = azurerm_virtual_network_peering.test1.virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network_peering.test1.remote_virtual_network_id
  allow_virtual_network_access = azurerm_virtual_network_peering.test1.allow_virtual_network_access
}
