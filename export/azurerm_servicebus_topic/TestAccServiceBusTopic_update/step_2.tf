
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011402789995"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230512011402789995"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                      = "acctestservicebustopic-230512011402789995"
  namespace_id              = azurerm_servicebus_namespace.test.id
  enable_batched_operations = true
  enable_express            = true
}
