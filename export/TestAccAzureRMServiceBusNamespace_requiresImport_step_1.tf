

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045157964467"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-210825045157964467"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "basic"
}


resource "azurerm_servicebus_namespace" "import" {
  name                = azurerm_servicebus_namespace.test.name
  location            = azurerm_servicebus_namespace.test.location
  resource_group_name = azurerm_servicebus_namespace.test.resource_group_name
  sku                 = azurerm_servicebus_namespace.test.sku
}
