
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220916012108368896"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctyxg68"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}
