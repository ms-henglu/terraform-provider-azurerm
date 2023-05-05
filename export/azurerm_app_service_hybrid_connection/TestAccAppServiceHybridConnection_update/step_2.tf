

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505051515526487"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctest-ASP-230505051515526487"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctest-AS-230505051515526487"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-RN-230505051515526487"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctest-RHC-230505051515526487"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
  user_metadata        = "metadatatest"
}

resource "azurerm_app_service_hybrid_connection" "test" {
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
  relay_id            = azurerm_relay_hybrid_connection.test.id
  hostname            = "changedhostname.azuretest"
  port                = 80
  send_key_name       = "RootManageSharedAccessKey"
}
