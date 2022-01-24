


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-diskspool-220124122049466609"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-220124122049466609"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-220124122049466609"
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


resource "azurerm_storage_disks_pool" "test" {
  name                = "acctest-diskspool-g88hn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  availability_zones  = ["1"]
  sku_name            = "Basic_B1"
  subnet_id           = azurerm_subnet.test.id
}


resource "azurerm_storage_disks_pool" "import" {
  name                = azurerm_storage_disks_pool.test.name
  resource_group_name = azurerm_storage_disks_pool.test.resource_group_name
  location            = azurerm_storage_disks_pool.test.location
  availability_zones  = azurerm_storage_disks_pool.test.availability_zones
  sku_name            = azurerm_storage_disks_pool.test.sku_name
  subnet_id           = azurerm_storage_disks_pool.test.subnet_id
}
