

provider "azurerm" {
  alias = "all1"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-230929065354335137"
  location = "westus2"

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true",
    "SkipNRMSNSG"      = "true"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-230929065354335137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-230929065354335137"
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
  name                = "acctest-NetAppAccount-230929065354335137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-230929065354335137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4
  qos_type            = "Manual"

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}


resource "azurerm_netapp_volume" "test" {
  name                = "acctest-NetAppVolume-230929065354335137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  service_level       = "Standard"
  volume_path         = "my-unique-file-path-230929065354335137"
  subnet_id           = azurerm_subnet.test.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 101
  throughput_in_mibps = 1.562

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = false
    unix_read_write   = true
  }

  export_policy_rule {
    rule_index        = 2
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = true
    unix_read_write   = false
  }

  export_policy_rule {
    rule_index        = 3
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = true
    unix_read_write   = false
  }

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "FoO"              = "BaR",
    "SkipASMAzSecPack" = "true"
  }
}
