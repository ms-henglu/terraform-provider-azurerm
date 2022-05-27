
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034437844384"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbns-e4a0r"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name                = "acctestsbrule-e4a0r"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-220527034437844384"

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
