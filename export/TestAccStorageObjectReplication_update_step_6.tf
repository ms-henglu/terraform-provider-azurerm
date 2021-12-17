

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "src" {
  name     = "acctest-storage-src-211217035952660780"
  location = "West Europe"
}

resource "azurerm_storage_account" "src" {
  name                     = "stracctsrcnmhgw"
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
  name                  = "strcsrcnmhgw"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "src_second" {
  name                  = "strcsrcsecondnmhgw"
  storage_account_name  = azurerm_storage_account.src.name
  container_access_type = "private"
}

resource "azurerm_resource_group" "dst" {
  name     = "acctest-storage-dst-211217035952660780"
  location = "West US 2"
}

resource "azurerm_storage_account" "dst" {
  name                     = "stracctdstnmhgw"
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
  name                  = "strcdstnmhgw"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dst_second" {
  name                  = "strcdstsecondnmhgw"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}


resource "azurerm_storage_object_replication" "test" {
  source_storage_account_id      = azurerm_storage_account.src.id
  destination_storage_account_id = azurerm_storage_account.dst.id
  rules {
    source_container_name        = azurerm_storage_container.src.name
    destination_container_name   = azurerm_storage_container.dst.name
    copy_blobs_created_after     = "2021-12-17T18:59:00Z"
    filter_out_blobs_with_prefix = ["blobA", "blobB", "blobC"]
  }
  rules {
    source_container_name      = azurerm_storage_container.src_second.name
    destination_container_name = azurerm_storage_container.dst_second.name
    copy_blobs_created_after   = "Everything"
  }
}
