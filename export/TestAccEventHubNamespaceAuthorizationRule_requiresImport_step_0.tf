
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-211008044423659203"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-211008044423659203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR211008044423659203"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}
