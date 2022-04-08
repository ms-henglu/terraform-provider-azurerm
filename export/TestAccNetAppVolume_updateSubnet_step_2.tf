

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220408051637726947"
  location = "East US 2"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-220408051637726947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-220408051637726947"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.6.2.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220408051637726947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-220408051637726947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4
}


resource "azurerm_virtual_network" "updated" {
  name                = "acctest-updated-VirtualNetwork-220408051637726947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "updated" {
  name                 = "acctest-updated-Subnet-220408051637726947"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.updated.name
  address_prefixes     = ["10.1.3.0/24"]

  delegation {
    name = "testdelegation2"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_volume" "test" {
  name                = "acctest-updated-NetAppVolume-220408051637726947"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_path         = "my-updated-unique-file-path-220408051637726947"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.updated.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 100
  throughput_in_mibps = 1.6
}
