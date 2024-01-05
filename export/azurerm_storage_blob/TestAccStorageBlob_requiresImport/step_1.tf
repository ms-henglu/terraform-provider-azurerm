


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064703861788"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestaccq64i4"
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

resource "azurerm_storage_blob" "source" {
  name                   = "example.vhd"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_uri             = "http://old-releases.ubuntu.com/releases/bionic/ubuntu-18.04-desktop-amd64.iso"
  content_type           = "application/x-iso9660-image"
}

resource "azurerm_storage_container" "second" {
  name                  = "second"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test" {
  name                   = "copied.vhd"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.second.name
  type                   = "Block"
  source_uri             = azurerm_storage_blob.source.id
  content_type           = azurerm_storage_blob.source.content_type
}


resource "azurerm_storage_blob" "import" {
  name                   = azurerm_storage_blob.test.name
  storage_account_name   = azurerm_storage_blob.test.storage_account_name
  storage_container_name = azurerm_storage_blob.test.storage_container_name
  type                   = azurerm_storage_blob.test.type
  size                   = azurerm_storage_blob.test.size
}
