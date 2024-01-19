
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908573911"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct97bh1"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}
