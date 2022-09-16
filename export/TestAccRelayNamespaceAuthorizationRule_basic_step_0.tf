
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011934369917"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-220916011934369917"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_namespace_authorization_rule" "test" {
  name                = "acctestrnak-220916011934369917"
  namespace_name      = azurerm_relay_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}
