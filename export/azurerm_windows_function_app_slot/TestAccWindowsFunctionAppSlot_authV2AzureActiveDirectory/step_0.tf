
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-231016033329350175"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsatqs7o"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329350175"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
  
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-231016033329350175"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-231016033329350175"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  app_settings = {
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"
    active_directory_v2 {
      client_id                  = data.azurerm_client_config.current.client_id
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/ARM_TENANT_ID/v2.0"
    }
    login {}
  }
}
