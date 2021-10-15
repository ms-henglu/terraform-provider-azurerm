
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211015014900652969"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctt1o8b"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index-2.html"
    error_404_document = "404-2.html"
  }
}
