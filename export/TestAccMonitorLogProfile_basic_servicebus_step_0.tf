
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042542966118"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbns-sfg0w"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name                = "acctestsbrule-sfg0w"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-220712042542966118"

  categories = [
    "Action",
  ]

  locations = [
    "West Europe",
  ]

  servicebus_rule_id = azurerm_servicebus_namespace_authorization_rule.test.id

  retention_policy {
    enabled = false
  }
}
