
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-230922060536047283"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsabaq8n"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230922060536047283"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
  
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-230922060536047283"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-230922060536047283"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  app_settings = {
    "TESTCUSTOM_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"

    custom_oidc_v2 {
      name                          = "testcustom"
      client_id                     = "testCustomID"
      openid_configuration_endpoint = "https://oidc.testcustom.contoso.com/auth"
    }

    login {}
  }
}
