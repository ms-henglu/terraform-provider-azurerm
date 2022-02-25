

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-220225034520931848"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-220225034520931848"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220225034520931848"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name                = "acctest-220225034520931848"
  namespace_name      = azurerm_servicebus_namespace.test.name
  topic_name          = azurerm_servicebus_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220225034520931848"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_endpoint_servicebus_topic" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_id           = azurerm_iothub.test.id
  name                = "acctest"

  connection_string = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
}


resource "azurerm_iothub_endpoint_servicebus_topic" "import" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_id           = azurerm_iothub.test.id
  name                = "acctest"

  connection_string = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
}
