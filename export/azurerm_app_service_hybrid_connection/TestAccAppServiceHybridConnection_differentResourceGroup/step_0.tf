
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034930988338"
  location = "West Europe"
}

resource "azurerm_resource_group" "relay" {
  name     = "acctestRG-relay-231016034930988338"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctest-ASP-231016034930988338"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctest-AS-231016034930988338"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-RN-231016034930988338"
  location            = azurerm_resource_group.relay.location
  resource_group_name = azurerm_resource_group.relay.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctest-RHC-231016034930988338"
  resource_group_name  = azurerm_resource_group.relay.name
  relay_namespace_name = azurerm_relay_namespace.test.name
  user_metadata        = "metadatatest"
}

resource "azurerm_app_service_hybrid_connection" "test" {
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
  relay_id            = azurerm_relay_hybrid_connection.test.id
  hostname            = "testhostname.azuretest"
  port                = 443
  send_key_name       = "RootManageSharedAccessKey"
}
