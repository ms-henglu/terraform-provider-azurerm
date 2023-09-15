
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-230915022839870125"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsauyg6d"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230915022839870125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
  
}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-230915022839870125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_linux_function_app_slot" "test" {
  name                       = "acctest-LFAS-230915022839870125"
  function_app_id            = azurerm_linux_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  app_settings = {
    "APPLE_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"

    apple_v2 {
      client_id                  = "testAppleID"
      client_secret_setting_name = "APPLE_PROVIDER_AUTHENTICATION_SECRET"
    }

    login {}
  }
}
