
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-220916011459584394"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-220916011459584394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR220916011459584394"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}
