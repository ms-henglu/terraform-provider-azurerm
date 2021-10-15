
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "acctest1RG-211015014802669073"
  location = "West Europe"
}

resource "azurerm_resource_group" "secondary" {
  name     = "acctest2RG-211015014802669073"
  location = "West US 2"
}

resource "azurerm_servicebus_namespace" "primary_namespace_test" {
  name                = "acctest1-211015014802669073"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_namespace" "secondary_namespace_test" {
  name                = "acctest2-211015014802669073"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  sku                 = "Premium"
  capacity            = "1"
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "pairing_test" {
  name                 = "acctest-alias-211015014802669073"
  primary_namespace_id = azurerm_servicebus_namespace.primary_namespace_test.id
  partner_namespace_id = azurerm_servicebus_namespace.secondary_namespace_test.id
}

