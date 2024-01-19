

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119022933275979"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccrqahr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


resource "azurerm_storage_container" "test2" {
  name                  = "vhds2"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_blob_inventory_policy" "test" {
  storage_account_id = azurerm_storage_account.test.id
  rules {
    name                   = "rule1"
    storage_container_name = azurerm_storage_container.test2.name
    format                 = "Parquet"
    schedule               = "Weekly"
    scope                  = "Blob"
    schema_fields = [
      "Name",
      "Creation-Time",
      "VersionId",
      "IsCurrentVersion",
      "Snapshot",
      "BlobType",
      "Deleted",
      "RemainingRetentionDays",
    ]
    filter {
      blob_types            = ["blockBlob", "pageBlob"]
      include_blob_versions = true
      include_deleted       = true
      include_snapshots     = true
      prefix_match          = ["*/test"]
      exclude_prefixes      = ["syslog.log"]
    }
  }
}
