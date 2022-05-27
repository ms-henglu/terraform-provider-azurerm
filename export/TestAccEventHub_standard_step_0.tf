
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-220527034159386488"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-220527034159386488"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-EH-220527034159386488"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 7
}
