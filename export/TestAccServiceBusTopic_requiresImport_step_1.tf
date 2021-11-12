

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021228939031"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211112021228939031"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211112021228939031"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_servicebus_topic" "import" {
  name                = azurerm_servicebus_topic.test.name
  namespace_name      = azurerm_servicebus_topic.test.namespace_name
  resource_group_name = azurerm_servicebus_topic.test.resource_group_name
}
