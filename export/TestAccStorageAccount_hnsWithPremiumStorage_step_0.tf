
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220603005354800925"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                      = "acctestsag0xxi"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  account_kind              = "BlockBlobStorage"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  is_hns_enabled            = true
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
}
