
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700858636"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700858636"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                      = "acctestservicebustopic-231016034700858636"
  namespace_id              = azurerm_servicebus_namespace.test.id
  enable_batched_operations = true
  enable_express            = true
}
