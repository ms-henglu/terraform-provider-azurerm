
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005308734524"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220603005308734524"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                  = "acctestservicebusqueue-220603005308734524"
  namespace_id          = azurerm_servicebus_namespace.test.id
  enable_partitioning   = true
  max_size_in_megabytes = 5120
}
