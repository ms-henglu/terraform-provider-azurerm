
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075434788775"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230616075434788775"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                                    = "acctestservicebustopic-230616075434788775"
  namespace_id                            = azurerm_servicebus_namespace.test.id
  auto_delete_on_idle                     = "PT10M"
  default_message_ttl                     = "PT30M"
  requires_duplicate_detection            = true
  duplicate_detection_history_time_window = "PT15M"
}
