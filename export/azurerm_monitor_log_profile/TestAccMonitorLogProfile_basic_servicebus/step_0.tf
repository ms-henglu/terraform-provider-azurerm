
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013922366604"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbns-k3mfy"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctestsbrule-k3mfy"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-221111013922366604"

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
