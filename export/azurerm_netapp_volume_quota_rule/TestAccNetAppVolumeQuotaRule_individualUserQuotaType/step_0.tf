

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-230922061614484561"
  location = "West Europe"

  tags = {
    "CreatedOnDate"    = "2023-08-17T08:01:00Z",
    "SkipASMAzSecPack" = "true",
    "SkipNRMSNSG"      = "true"
  }
}

resource "azurerm_network_security_group" "test" {
  name                = "acctest-NSG-230922061614484561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2023-08-17T08:01:00Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-230922061614484561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "CreatedOnDate"    = "2023-08-17T08:01:00Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-DelegatedSubnet-230922061614484561"
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

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-230922061614484561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2023-08-17T08:01:00Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-230922061614484561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4
  qos_type            = "Auto"

  tags = {
    "CreatedOnDate"    = "2023-08-17T08:01:00Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_volume" "test" {
  name                = "acctest-NetAppVolume-230922061614484561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  pool_name           = azurerm_netapp_pool.test.name
  volume_path         = "my-unique-file-path-230922061614484561"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.test.id
  storage_quota_in_gb = 100
  protocols           = ["NFSv3"]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}


resource "azurerm_netapp_volume_quota_rule" "test" {
  name              = "acctest-NetAppVolumeQuotaRule-230922061614484561"
  location          = azurerm_resource_group.test.location
  volume_id         = azurerm_netapp_volume.test.id
  quota_target      = "3001"
  quota_size_in_kib = 1024
  quota_type        = "IndividualUserQuota"
}
