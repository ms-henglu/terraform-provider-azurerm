
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014235146829"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221111014235146829"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                  = "acctestservicebustopic-221111014235146829"
  namespace_id          = azurerm_servicebus_namespace.test.id
  enable_partitioning   = true
  max_size_in_megabytes = 5120
}
