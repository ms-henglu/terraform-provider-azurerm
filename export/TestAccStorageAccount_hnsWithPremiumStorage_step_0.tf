
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211001021258831218"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                      = "acctestsazl9tw"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  account_kind              = "BlockBlobStorage"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  is_hns_enabled            = true
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
}
