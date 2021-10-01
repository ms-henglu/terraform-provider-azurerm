
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021223125861"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211001021223125861"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                                    = "acctestservicebustopic-211001021223125861"
  namespace_name                          = azurerm_servicebus_namespace.test.name
  resource_group_name                     = azurerm_resource_group.test.name
  auto_delete_on_idle                     = "PT10M"
  default_message_ttl                     = "PT30M"
  requires_duplicate_detection            = true
  duplicate_detection_history_time_window = "PT15M"
}
