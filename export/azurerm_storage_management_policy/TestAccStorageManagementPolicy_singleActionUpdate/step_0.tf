
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231016034824728779"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctccuvt"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
}

resource "azurerm_storage_management_policy" "test" {
  storage_account_id = azurerm_storage_account.test.id

  rule {
    name    = "singleActionRule"
    enabled = true
    filters {
      prefix_match = ["container1/prefix1"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 10
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}
