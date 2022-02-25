

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034955118585"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220225034955118585"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220225034955118585"
  namespace_id = azurerm_servicebus_namespace.test.id
}


resource "azurerm_servicebus_topic" "import" {
  name         = azurerm_servicebus_topic.test.name
  namespace_id = azurerm_servicebus_topic.test.namespace_id
}
