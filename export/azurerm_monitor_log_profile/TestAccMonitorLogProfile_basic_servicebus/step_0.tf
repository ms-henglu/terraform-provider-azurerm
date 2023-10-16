
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034326122866"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbns-r4gh6"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctestsbrule-r4gh6"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-231016034326122866"

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
