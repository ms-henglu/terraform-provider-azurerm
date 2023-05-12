
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011402768181"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230512011402768181"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                  = "acctestservicebusqueue-230512011402768181"
  namespace_id          = azurerm_servicebus_namespace.test.id
  enable_partitioning   = true
  max_size_in_megabytes = 5120
}
