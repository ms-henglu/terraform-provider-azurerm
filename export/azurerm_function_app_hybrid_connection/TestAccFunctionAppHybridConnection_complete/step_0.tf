
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117230506158614"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221117230506158614"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa4bpal"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctest-RN-221117230506158614"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctest-RHC-221117230506158614"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
  user_metadata        = "metadatatest"
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-221117230506158614"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_resource_group" "relay" {
  name     = "acctestRG-221117230506158614"
  location = "West Europe"
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



resource "azurerm_function_app_hybrid_connection" "test" {
  function_app_id = azurerm_windows_function_app.test.id
  relay_id        = azurerm_relay_hybrid_connection.test.id
  hostname        = "acctestccbr6io6.hostname"
  port            = 8081

  send_key_name = azurerm_relay_hybrid_connection_authorization_rule.test.name
}
