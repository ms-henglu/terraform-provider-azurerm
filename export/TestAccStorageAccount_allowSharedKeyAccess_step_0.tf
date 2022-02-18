
provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220218071345842647"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctf8c0i"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = false

  tags = {
    environment = "production"
  }
}
