
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230316221526713450"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-230316221526713450-rly-eventsub-repo"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                          = "acctest-230316221526713450-rhc-eventsub-repo"
  resource_group_name           = azurerm_resource_group.test.name
  relay_namespace_name          = azurerm_relay_namespace.test.name
  requires_client_authorization = false
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctest-230316221526713450-evg-eventsub-repo"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name                          = "acctest-eg-230316221526713450"
  scope                         = azurerm_eventgrid_topic.test.id
  hybrid_connection_endpoint_id = azurerm_relay_hybrid_connection.test.id

  delivery_property {
    header_name = "test-static-1"
    type        = "Static"
    value       = "1"
  }
}
