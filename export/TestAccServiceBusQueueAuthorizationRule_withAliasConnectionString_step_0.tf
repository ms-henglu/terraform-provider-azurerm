
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "acctest1RG-211013072356011960"
  location = "West Europe"
}

resource "azurerm_resource_group" "secondary" {
  name     = "acctest2RG-211013072356011960"
  location = "West US 2"
}

resource "azurerm_servicebus_namespace" "primary_namespace_test" {
  name                = "acctest1-211013072356011960"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_queue" "example" {
  name                = "queue-test"
  resource_group_name = azurerm_resource_group.primary.name
  namespace_name      = azurerm_servicebus_namespace.primary_namespace_test.name
}

resource "azurerm_servicebus_namespace" "secondary_namespace_test" {
  name                = "acctest2-211013072356011960"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "pairing_test" {
  name                 = "acctest-alias-211013072356011960"
  primary_namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
  partner_namespace_id = azurerm_servicebus_namespace.secondary_namespace_test.id
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name                = "example_queue_rule"
  namespace_name      = azurerm_servicebus_namespace.primary_namespace_test.name
  queue_name          = azurerm_servicebus_queue.example.name
  resource_group_name = azurerm_resource_group.primary.name
  manage              = true
  listen              = true
  send                = true

  depends_on = [
    azurerm_servicebus_namespace_disaster_recovery_config.pairing_test
  ]
}

