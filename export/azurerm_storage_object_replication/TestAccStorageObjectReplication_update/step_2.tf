

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "src" {
  name     = "acctest-storage-src-230512011501752072"
  location = "West Europe"
}

resource "azurerm_storage_account" "src" {
  name                     = "stracctsrch9fhz"
  resource_group_name      = azurerm_resource_group.src.name
  location                 = azurerm_resource_group.src.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }
}

resource "azurerm_storage_container" "src" {
  name                  = "strcsrch9fhz"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "src_second" {
  name                  = "strcsrcsecondh9fhz"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_resource_group" "dst" {
  name     = "acctest-storage-alt-230512011501752072"
  location = "West US 2"
}

resource "azurerm_storage_account" "dst" {
  name                     = "stracctdsth9fhz"
  resource_group_name      = azurerm_resource_group.dst.name
  location                 = azurerm_resource_group.dst.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }
}

resource "azurerm_storage_container" "dst" {
  name                  = "strcdsth9fhz"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dst_second" {
  name                  = "strcdstsecondh9fhz"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}


resource "azurerm_storage_object_replication" "test" {
  source_storage_account_id      = azurerm_storage_account.src.id
  destination_storage_account_id = azurerm_storage_account.dst.id
  rules {
    source_container_name        = azurerm_storage_container.src.name
    destination_container_name   = azurerm_storage_container.dst.name
    copy_blobs_created_after     = "Everything"
    filter_out_blobs_with_prefix = ["blobA", "blobB"]
  }
}
