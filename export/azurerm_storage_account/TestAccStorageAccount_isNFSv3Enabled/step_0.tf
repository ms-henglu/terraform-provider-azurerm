
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230922054956001094"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVNet-230922054956001094"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSubnet-230922054956001094"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct48bvf"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Premium"
  account_kind              = "BlockBlobStorage"
  account_replication_type  = "LRS"
  is_hns_enabled            = true
  nfsv3_enabled             = true
  enable_https_traffic_only = false
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.test.id]
  }
}
