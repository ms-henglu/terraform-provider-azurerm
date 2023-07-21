
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011121290427"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230721011121290427"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


data "azurerm_client_config" "current" {}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestLWA-230721011121290427"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  app_settings = {
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  sticky_settings {
    app_setting_names = ["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"]
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "RedirectToLoginPage"

    microsoft_v2 {
      client_id                  = "testMSFTID"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }

    login {}
  }
}
