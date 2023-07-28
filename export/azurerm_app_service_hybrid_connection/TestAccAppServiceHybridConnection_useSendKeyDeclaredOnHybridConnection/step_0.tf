
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033254835375"
  location = "West Europe"
}

resource "azurerm_resource_group" "relay" {
  name     = "acctestRG-relay-230728033254835375"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctest-ASP-230728033254835375"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctest-AS-230728033254835375"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-RN-230728033254835375"
  location            = azurerm_resource_group.relay.location
  resource_group_name = azurerm_resource_group.relay.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctest-RHC-230728033254835375"
  resource_group_name  = azurerm_resource_group.relay.name
  relay_namespace_name = azurerm_relay_namespace.test.name
  user_metadata        = "metadatatest"
}

resource "azurerm_relay_hybrid_connection_authorization_rule" "test" {
  name                   = "sendKey"
  resource_group_name    = azurerm_resource_group.relay.name
  hybrid_connection_name = azurerm_relay_hybrid_connection.test.name
  namespace_name         = azurerm_relay_namespace.test.name

  listen = true
  send   = true
  manage = false
}

resource "azurerm_app_service_hybrid_connection" "test" {
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
  relay_id            = azurerm_relay_hybrid_connection.test.id
  hostname            = "testhostname.azuretest"
  port                = 443
  send_key_name       = azurerm_relay_hybrid_connection_authorization_rule.test.name
}
