

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181707533574"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230113181707533574"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}


resource "azurerm_servicebus_namespace" "import" {
  name                = azurerm_servicebus_namespace.test.name
  location            = azurerm_servicebus_namespace.test.location
  resource_group_name = azurerm_servicebus_namespace.test.resource_group_name
  sku                 = azurerm_servicebus_namespace.test.sku
}
