
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "acctest1RG-221202040436374050"
  location = "West Europe"
}

resource "azurerm_resource_group" "secondary" {
  name     = "acctest2RG-221202040436374050"
  location = "West US 2"
}

resource "azurerm_servicebus_namespace" "primary_namespace_test" {
  name                = "acctest1-221202040436374050"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_topic" "example" {
  name         = "topic-test"
  namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
}

resource "azurerm_servicebus_namespace" "secondary_namespace_test" {
  name                = "acctest2-221202040436374050"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "pairing_test" {
  name                 = "acctest-alias-221202040436374050"
  primary_namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
  partner_namespace_id = azurerm_servicebus_namespace.secondary_namespace_test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "example_topic_rule"
  topic_id = azurerm_servicebus_topic.example.id
  manage   = true
  listen   = true
  send     = true

  depends_on = [
    azurerm_servicebus_namespace_disaster_recovery_config.pairing_test
  ]
}
