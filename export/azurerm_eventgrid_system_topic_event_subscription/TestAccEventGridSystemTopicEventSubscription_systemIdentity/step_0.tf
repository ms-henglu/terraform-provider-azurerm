
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230915023410423147"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccugh7v"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230915023410423147"
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

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-230915023410423147"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_resource_group.test.id
  topic_type             = "Microsoft.Resources.ResourceGroups"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_eventgrid_system_topic.test.identity.0.principal_id
}

resource "azurerm_role_assignment" "sender" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Message Sender"
  principal_id         = azurerm_eventgrid_system_topic.test.identity.0.principal_id
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test" {
  name                = "acctesteg-230915023410423147"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

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
