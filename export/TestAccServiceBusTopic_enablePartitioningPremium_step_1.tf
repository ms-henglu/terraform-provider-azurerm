
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004838642338"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-210924004838642338"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                  = "acctestservicebustopic-210924004838642338"
  namespace_name        = azurerm_servicebus_namespace.test.name
  resource_group_name   = azurerm_resource_group.test.name
  enable_partitioning   = false
  max_size_in_megabytes = 81920
}
