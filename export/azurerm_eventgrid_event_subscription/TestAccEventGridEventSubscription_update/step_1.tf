
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230922061117490871"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc46gha"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230922061117490871"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test" {
  name = "herpderp1.vhd"

  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name

  type = "Page"
  size = 5120
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctest-eg-230922061117490871"
  scope = azurerm_resource_group.test.id

  storage_queue_endpoint {
    storage_account_id                    = azurerm_storage_account.test.id
    queue_name                            = azurerm_storage_queue.test.name
    queue_message_time_to_live_in_seconds = 3600
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = azurerm_storage_account.test.id
    storage_blob_container_name = azurerm_storage_container.test.name
  }

  retry_policy {
    event_time_to_live    = 12
    max_delivery_attempts = 10
  }

  subject_filter {
    subject_begins_with = "test/test"
    subject_ends_with   = ".jpg"
  }

  included_event_types = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobDeleted"]
  labels               = ["test4", "test5", "test6"]
}
