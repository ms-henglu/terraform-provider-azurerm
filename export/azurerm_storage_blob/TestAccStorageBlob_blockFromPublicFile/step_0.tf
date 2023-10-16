

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034824452633"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestacckq40e"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


provider "azurerm" {
  features {}
}

resource "azurerm_storage_blob" "test" {
  name                   = "example.vhd"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_uri             = "http://old-releases.ubuntu.com/releases/bionic/ubuntu-18.04-desktop-amd64.iso"
  content_type           = "application/x-iso9660-image"
}
