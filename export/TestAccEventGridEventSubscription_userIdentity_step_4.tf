
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-211210024605782517"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccsfs8x"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211210024605782517"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_container" "test" {
  name                  = "dead-letter-destination"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-211210024605782517"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctesteg-211210024605782517"
  scope = azurerm_resource_group.test.id

  delivery_identity {
    type                   = "UserAssigned"
    user_assigned_identity = azurerm_user_assigned_identity.test.id
  }

  dead_letter_identity {
    type                   = "UserAssigned"
    user_assigned_identity = azurerm_user_assigned_identity.test.id
  }

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.test.id
    queue_name         = azurerm_storage_queue.test.name
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = azurerm_storage_account.test.id
    storage_blob_container_name = azurerm_storage_container.test.name
  }

}
