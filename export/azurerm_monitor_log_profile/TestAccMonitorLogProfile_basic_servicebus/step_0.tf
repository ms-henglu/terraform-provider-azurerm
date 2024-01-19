
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423993948"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbns-pmc1z"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctestsbrule-pmc1z"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-240119025423993948"

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
