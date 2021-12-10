

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211210024854777261"
  location = "East US 2"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-211210024854777261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-211210024854777261"
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
  name                = "acctest-NetAppAccount-211210024854777261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-211210024854777261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4
}


resource "azurerm_netapp_volume" "test" {
  name                = "acctest-NetAppVolume-211210024854777261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  service_level       = "Standard"
  volume_path         = "my-unique-file-path-211210024854777261"
  subnet_id           = azurerm_subnet.test.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 101

  export_policy_rule {
    rule_index          = 1
    allowed_clients     = ["1.2.4.0/24", "1.3.4.0"]
    protocols_enabled   = ["NFSv3"]
    unix_read_only      = false
    unix_read_write     = true
    root_access_enabled = true
  }

  tags = {
    "FoO" = "BaR"
  }
}
