
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-240119022053138672"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccfuxda"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-240119022053138672"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_container" "test" {
  name                  = "dead-letter-destination"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240119022053138672"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_eventgrid_topic.test.identity.0.principal_id
}

resource "azurerm_role_assignment" "sender" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Message Sender"
  principal_id         = azurerm_eventgrid_topic.test.identity.0.principal_id
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctesteg-240119022053138672"
  scope = azurerm_eventgrid_topic.test.id

  delivery_identity {
    type = "SystemAssigned"
  }

  dead_letter_identity {
    type = "SystemAssigned"
  }

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.test.id
    queue_name         = azurerm_storage_queue.test.name
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = azurerm_storage_account.test.id
    storage_blob_container_name = azurerm_storage_container.test.name
  }

  depends_on = [
    azurerm_role_assignment.contributor,
    azurerm_role_assignment.sender
  ]

}
