

provider "azurerm" {
  alias = "all1"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220630224001964517"
  location = "westus2"

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-220630224001964517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-Subnet-220630224001964517"
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
  name                = "acctest-NetAppAccount-220630224001964517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-220630224001964517"
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
  name                = "acctest-NetAppVolume-220630224001964517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_path         = "my-unique-file-path-220630224001964517"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.test.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 100
  throughput_in_mibps = 1.6

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = ["1.2.3.0/24"]
    protocols_enabled = ["NFSv3"]
    unix_read_only    = false
    unix_read_write   = true
  }

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_snapshot" "test" {
  name                = "acctest-Snapshot-220630224001964517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_name         = azurerm_netapp_volume.test.name
}

resource "azurerm_netapp_volume" "test_snapshot_vol" {
  name                             = "acctest-NetAppVolume-NewFromSnapshot-220630224001964517"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  account_name                     = azurerm_netapp_account.test.name
  pool_name                        = azurerm_netapp_pool.test.name
  volume_path                      = "my-unique-file-path-snapshot-220630224001964517"
  service_level                    = "Standard"
  subnet_id                        = azurerm_subnet.test.id
  protocols                        = ["NFSv3"]
  storage_quota_in_gb              = 200
  create_from_snapshot_resource_id = azurerm_netapp_snapshot.test.id
  throughput_in_mibps              = 3.2

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_write   = true
  }

  tags = {
    "SkipASMAzSecPack" = "true"
  }
}
