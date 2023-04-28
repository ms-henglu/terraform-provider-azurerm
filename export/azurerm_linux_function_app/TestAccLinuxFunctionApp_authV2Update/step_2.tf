
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-230428045153744314"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsak4yi7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230428045153744314"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
  
}


data "azurerm_client_config" "current" {}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-230428045153744314"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  app_settings = {
    "GOOGLE_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  sticky_settings {
    app_setting_names = ["GOOGLE_PROVIDER_AUTHENTICATION_SECRET"]
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "RedirectToLoginPage"

    google_v2 {
      client_id                  = "testGoogleID"
      client_secret_setting_name = "GOOGLE_PROVIDER_AUTHENTICATION_SECRET"
    }

    login {}
  }
}
