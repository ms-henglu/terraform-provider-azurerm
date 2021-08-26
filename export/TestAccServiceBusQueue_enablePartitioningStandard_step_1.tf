
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023827995982"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-210826023827995982"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                  = "acctestservicebusqueue-210826023827995982"
  resource_group_name   = azurerm_resource_group.test.name
  namespace_name        = azurerm_servicebus_namespace.test.name
  enable_partitioning   = true
  max_size_in_megabytes = 5120
}
