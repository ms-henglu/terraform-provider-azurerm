
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-220826002735986327"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220826002735986327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-220826002735986327"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 5
  message_retention   = 1
  status              = "Active"
}
