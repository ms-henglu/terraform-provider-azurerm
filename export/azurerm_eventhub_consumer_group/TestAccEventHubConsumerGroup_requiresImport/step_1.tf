

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eh-240315123049379481"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240315123049379481"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240315123049379481"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-240315123049379481"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventhub_consumer_group" "import" {
  name                = azurerm_eventhub_consumer_group.test.name
  namespace_name      = azurerm_eventhub_consumer_group.test.namespace_name
  eventhub_name       = azurerm_eventhub_consumer_group.test.eventhub_name
  resource_group_name = azurerm_eventhub_consumer_group.test.resource_group_name
}
