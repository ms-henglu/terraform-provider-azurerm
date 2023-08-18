
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230818024852421581"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctvgjbm"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "ZRS"

  share_properties {
    smb {
      multichannel_enabled = true
    }
  }
}
