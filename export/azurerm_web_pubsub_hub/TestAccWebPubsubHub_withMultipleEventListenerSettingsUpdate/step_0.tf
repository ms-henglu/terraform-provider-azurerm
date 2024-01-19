

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-240119022853625802"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-240119022853625802"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240119022853625802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240119022853625802"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub" "test1" {
  name                = "acctesteventhub-240119022853625802"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh240119022853625802"
  web_pubsub_id = azurerm_web_pubsub.test.id

  event_listener {
    system_event_name_filter = ["disconnected", "connected"]
    user_event_name_filter   = ["event1"]
    eventhub_namespace_name  = azurerm_eventhub_namespace.test.name
    eventhub_name            = azurerm_eventhub.test.name
  }

  event_listener {
    system_event_name_filter = ["connected"]
    user_event_name_filter   = ["event1", "event2"]
    eventhub_namespace_name  = azurerm_eventhub_namespace.test.name
    eventhub_name            = azurerm_eventhub.test1.name
  }
}
