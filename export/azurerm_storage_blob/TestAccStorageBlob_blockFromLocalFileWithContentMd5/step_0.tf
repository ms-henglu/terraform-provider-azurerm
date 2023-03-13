

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313022003138330"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestacc73fp1"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
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
  source                 = "/tmp/2463600470"
  content_md5            = "${filemd5("/tmp/2463600470")}"
}
