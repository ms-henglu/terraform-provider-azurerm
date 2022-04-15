
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "acctest1RG-220415031106384334"
  location = "West Europe"
}

resource "azurerm_resource_group" "secondary" {
  name     = "acctest2RG-220415031106384334"
  location = "West US 2"
}

resource "azurerm_servicebus_namespace" "primary_namespace_test" {
  name                = "acctest1-220415031106384334"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_queue" "example" {
  name         = "queue-test"
  namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
}

resource "azurerm_servicebus_namespace" "secondary_namespace_test" {
  name                = "acctest2-220415031106384334"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "pairing_test" {
  name                 = "acctest-alias-220415031106384334"
  primary_namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
  partner_namespace_id = azurerm_servicebus_namespace.secondary_namespace_test.id
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name     = "example_queue_rule"
  queue_id = azurerm_servicebus_queue.example.id
  manage   = true
  listen   = true
  send     = true

  depends_on = [
    azurerm_servicebus_namespace_disaster_recovery_config.pairing_test
  ]
}
