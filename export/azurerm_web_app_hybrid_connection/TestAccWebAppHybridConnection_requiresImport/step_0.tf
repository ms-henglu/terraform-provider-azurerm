
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021030829341417"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221021030829341417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-RN-221021030829341417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctest-RHC-221021030829341417"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
  user_metadata        = "metadatatest"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-221021030829341417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_web_app_hybrid_connection" "test" {
  web_app_id = azurerm_windows_web_app.test.id
  relay_id   = azurerm_relay_hybrid_connection.test.id
  hostname   = "acctestoq2qz46w.hostname"
  port       = 8081
}
