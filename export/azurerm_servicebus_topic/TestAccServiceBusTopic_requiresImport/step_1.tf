

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106035029148694"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230106035029148694"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230106035029148694"
  namespace_id = azurerm_servicebus_namespace.test.id
}


resource "azurerm_servicebus_topic" "import" {
  name         = azurerm_servicebus_topic.test.name
  namespace_id = azurerm_servicebus_topic.test.namespace_id
}
