


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211013072205181944"
  location = "East US 2"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-211013072205181944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-211013072205181944"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.6.2.0/24"

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-211013072205181944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-211013072205181944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4
}


resource "azurerm_virtual_network" "test_secondary" {
  name                = "acctest-VirtualNetwork-secondary-211013072205181944"
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "test_secondary" {
  name                 = "acctest-Subnet-secondary-211013072205181944"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test_secondary.name
  address_prefix       = "10.6.2.0/24"

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "test_secondary" {
  name                = "acctest-NetAppAccount-secondary-211013072205181944"
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test_secondary" {
  name                = "acctest-NetAppPool-secondary-211013072205181944"
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test_secondary.name
  service_level       = "Standard"
  size_in_tb          = 4
}


resource "azurerm_netapp_volume" "test_primary" {
  name                = "acctest-NetAppVolume-primary-211013072205181944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_path         = "my-unique-file-path-primary-211013072205181944"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.test.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 100

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = false
    unix_read_write   = true
  }
}

resource "azurerm_netapp_volume" "test_secondary" {
  name                       = "acctest-NetAppVolume-secondary-211013072205181944"
  location                   = "germanywestcentral"
  resource_group_name        = azurerm_resource_group.test.name
  account_name               = azurerm_netapp_account.test_secondary.name
  pool_name                  = azurerm_netapp_pool.test_secondary.name
  volume_path                = "my-unique-file-path-secondary-211013072205181944"
  service_level              = "Standard"
  subnet_id                  = azurerm_subnet.test_secondary.id
  protocols                  = ["NFSv3"]
  storage_quota_in_gb        = 100
  snapshot_directory_visible = false

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = false
    unix_read_write   = true
  }

  data_protection_replication {
    endpoint_type             = "dst"
    remote_volume_location    = azurerm_resource_group.test.location
    remote_volume_resource_id = azurerm_netapp_volume.test_primary.id
    replication_frequency     = "10minutes"
  }
}
