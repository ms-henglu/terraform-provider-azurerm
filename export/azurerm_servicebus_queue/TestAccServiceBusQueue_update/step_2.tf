
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222306212036"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230316222306212036"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                      = "acctestservicebusqueue-230316222306212036"
  namespace_id              = azurerm_servicebus_namespace.test.id
  enable_express            = true
  max_size_in_megabytes     = 2048
  enable_batched_operations = false
}
