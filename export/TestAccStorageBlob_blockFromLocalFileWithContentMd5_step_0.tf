

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203162006426527"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccc2jys"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}


provider "azurerm" {
  features {}
}

resource "azurerm_storage_blob" "test" {
  name                   = "example.vhd"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source                 = "/tmp/318034590"
  content_md5            = "${filemd5("/tmp/318034590")}"
}
