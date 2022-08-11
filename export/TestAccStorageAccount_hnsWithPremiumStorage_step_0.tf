
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220811053928082746"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                      = "acctestsax2ar7"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  account_kind              = "BlockBlobStorage"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  is_hns_enabled            = true
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
}
