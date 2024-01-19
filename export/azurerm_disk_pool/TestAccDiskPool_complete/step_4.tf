
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-diskspool-240119024942811579"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240119024942811579"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-240119024942811579"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/24"]
  delegation {
    name = "diskspool"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/read"]
      name    = "Microsoft.StoragePool/diskPools"
    }
  }
}


resource "azurerm_disk_pool" "test" {
  name                = "acctest-diskspool-csqgp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Basic_B1"
  subnet_id           = azurerm_subnet.test.id
  zones               = ["1"]
  tags = {
    ENV = "Test"
  }
}
