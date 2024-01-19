
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025804611366"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-240119025804611366"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                                    = "acctestservicebusqueue-240119025804611366"
  namespace_id                            = azurerm_servicebus_namespace.test.id
  auto_delete_on_idle                     = "PT10M"
  default_message_ttl                     = "PT30M"
  requires_duplicate_detection            = true
  duplicate_detection_history_time_window = "PT15M"
}
