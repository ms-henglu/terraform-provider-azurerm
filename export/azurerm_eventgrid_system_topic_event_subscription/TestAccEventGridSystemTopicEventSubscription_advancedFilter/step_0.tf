
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-221124181641343633"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc4htzb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-221124181641343633"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-221124181641343633"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_resource_group.test.id
  topic_type             = "Microsoft.Resources.ResourceGroups"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test1" {
  name                = "acctesteg-221124181641343633-1"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

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
      value = 1
    }
    number_greater_than_or_equals {
      key   = "data.contentLength"
      value = 42.0
    }
    number_less_than {
      key   = "data.contentLength"
      value = 42.1
    }
    number_less_than_or_equals {
      key   = "data.metadataVersion"
      value = 2
    }
    number_in {
      key    = "data.contentLength"
      values = [0, 1, 1, 2, 3]
    }
    number_not_in {
      key    = "data.contentLength"
      values = [5, 8, 13, 21, 34]
    }
    number_in_range {
      key    = "data.contentLength"
      values = [[0, 1], [2, 3]]
    }
    number_not_in_range {
      key    = "data.contentLength"
      values = [[5, 13], [21, 34]]
    }
    string_begins_with {
      key    = "subject"
      values = ["foo"]
    }
  }
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test2" {
  name                = "acctesteg-221124181641343633-2"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.test.id
    queue_name         = azurerm_storage_queue.test.name
  }

  advanced_filter {
    string_ends_with {
      key    = "subject"
      values = ["bar"]
    }
    string_not_begins_with {
      key    = "subject"
      values = ["lorem"]
    }
    string_not_ends_with {
      key    = "subject"
      values = ["ipsum"]
    }
    string_not_contains {
      key    = "data.contentType"
      values = ["text"]
    }
    string_contains {
      key    = "data.contentType"
      values = ["application", "octet-stream"]
    }
    string_in {
      key    = "data.blobType"
      values = ["Block"]
    }
    string_not_in {
      key    = "data.blobType"
      values = ["Page"]
    }
    is_not_null {
      key = "subject"
    }
    is_null_or_undefined {
      key = "subject"
    }
  }
}
