

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "src" {
  name     = "acctest-storage-src-220225035100711157"
  location = "West Europe"
}

resource "azurerm_storage_account" "src" {
  name                     = "stracctsrcxclq7"
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
  name                  = "strcsrcxclq7"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "src_second" {
  name                  = "strcsrcsecondxclq7"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_resource_group" "dst" {
  name     = "acctest-storage-dst-220225035100711157"
  location = "West US 2"
}

resource "azurerm_storage_account" "dst" {
  name                     = "stracctdstxclq7"
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
  name                  = "strcdstxclq7"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dst_second" {
  name                  = "strcdstsecondxclq7"
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
