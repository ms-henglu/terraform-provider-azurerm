
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-240311032056394520"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccefxln"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-240311032056394520"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctest-eg-240311032056394520"
  scope = azurerm_resource_group.test.id

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.test.id
    queue_name         = azurerm_storage_queue.test.name
  }

  advanced_filtering_on_arrays_enabled = true

  included_event_types = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobDeleted"]

  subject_filter {
    subject_begins_with = "test/test"
    subject_ends_with   = ".jpg"
  }
}
