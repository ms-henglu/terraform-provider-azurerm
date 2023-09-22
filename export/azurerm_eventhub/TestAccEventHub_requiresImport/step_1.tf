

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-230922054138849543"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230922054138849543"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-230922054138849543"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}


resource "azurerm_eventhub" "import" {
  name                = azurerm_eventhub.test.name
  namespace_name      = azurerm_eventhub.test.namespace_name
  resource_group_name = azurerm_eventhub.test.resource_group_name
  partition_count     = azurerm_eventhub.test.partition_count
  message_retention   = azurerm_eventhub.test.message_retention
}
