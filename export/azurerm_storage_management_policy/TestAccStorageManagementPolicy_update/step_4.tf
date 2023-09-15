
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230915024302448990"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctobpph"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
}

resource "azurerm_storage_management_policy" "test" {
  storage_account_id = azurerm_storage_account.test.id

  rule {
    name    = "rule2"
    enabled = true
    filters {
      prefix_match = ["container2/prefix2"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than        = 11
        tier_to_archive_after_days_since_modification_greater_than     = 51
        tier_to_archive_after_days_since_last_tier_change_greater_than = 20
        delete_after_days_since_modification_greater_than              = 101
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation               = 91
        tier_to_archive_after_days_since_last_tier_change_greater_than = 20
        change_tier_to_cool_after_days_since_creation                  = 24
        delete_after_days_since_creation_greater_than                  = 31
      }
      version {
        change_tier_to_archive_after_days_since_creation               = 10
        tier_to_archive_after_days_since_last_tier_change_greater_than = 20
        change_tier_to_cool_after_days_since_creation                  = 91
        delete_after_days_since_creation                               = 4
      }
    }
  }
}
