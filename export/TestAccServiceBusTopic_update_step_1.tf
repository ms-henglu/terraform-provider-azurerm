
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014802688350"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211015014802688350"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                      = "acctestservicebustopic-211015014802688350"
  namespace_name            = azurerm_servicebus_namespace.test.name
  resource_group_name       = azurerm_resource_group.test.name
  enable_batched_operations = true
  enable_express            = true
}
