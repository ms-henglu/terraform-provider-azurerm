
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021223122146"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211001021223122146"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                         = "acctestservicebustopic-211001021223122146"
  namespace_name               = azurerm_servicebus_namespace.test.name
  resource_group_name          = azurerm_resource_group.test.name
  requires_duplicate_detection = true
}
