


provider "azurerm" {
  alias = "all1"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220623234107375848"
  location = "westus2"

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-220623234107375848"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-220623234107375848"
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
  name                = "acctest-NetAppAccount-220623234107375848"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-220623234107375848"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}


resource "azurerm_netapp_volume" "test" {
  name                = "acctest-NetAppVolume-220623234107375848"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_path         = "my-unique-file-path-220623234107375848"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.test.id
  storage_quota_in_gb = 100

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}


resource "azurerm_netapp_volume" "import" {
  name                = azurerm_netapp_volume.test.name
  location            = azurerm_netapp_volume.test.location
  resource_group_name = azurerm_netapp_volume.test.resource_group_name
  account_name        = azurerm_netapp_volume.test.account_name
  pool_name           = azurerm_netapp_volume.test.pool_name
  volume_path         = azurerm_netapp_volume.test.volume_path
  service_level       = azurerm_netapp_volume.test.service_level
  subnet_id           = azurerm_netapp_volume.test.subnet_id
  storage_quota_in_gb = azurerm_netapp_volume.test.storage_quota_in_gb
  throughput_in_mibps = azurerm_netapp_volume.test.throughput_in_mibps
}
