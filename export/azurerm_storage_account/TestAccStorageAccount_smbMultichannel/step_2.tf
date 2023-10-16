
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231016034824367681"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct4mx4a"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "ZRS"

  share_properties {
    smb {
      multichannel_enabled = false
    }
  }
}
