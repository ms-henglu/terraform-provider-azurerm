
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230602030516940812"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccq9uu9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230602030516940812"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctesteg-230602030516940812"
  scope = azurerm_storage_account.test.id

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.test.id
    queue_name         = azurerm_storage_queue.test.name
  }

  advanced_filter {
    bool_equals {
      key   = "subject"
      value = true
    }
    number_greater_than {
      key   = "data.metadataVersion"
      value = 2
    }
    number_greater_than_or_equals {
      key   = "data.contentLength"
      value = 3
    }
    number_less_than {
      key   = "data.contentLength"
      value = 4
    }
    number_less_than_or_equals {
      key   = "data.metadataVersion"
      value = 5
    }
    number_in {
      key    = "data.contentLength"
      values = [6, 7, 8]
    }
    number_not_in {
      key    = "data.contentLength"
      values = [9, 10, 11]
    }
    string_begins_with {
      key    = "subject"
      values = ["12", "13", "14"]
    }
    string_ends_with {
      key    = "subject"
      values = ["15", "16", "17"]
    }
    string_contains {
      key    = "data.contentType"
      values = ["18", "19", "20"]
    }
    string_in {
      key    = "data.blobType"
      values = ["21", "22", "23"]
    }
    string_not_in {
      key    = "data.blobType"
      values = ["24", "25"]
    }
  }

}
