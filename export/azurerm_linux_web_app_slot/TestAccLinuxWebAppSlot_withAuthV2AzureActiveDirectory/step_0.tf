
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030119199261"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-230602030119199261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-230602030119199261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_linux_web_app_slot" "test" {
  name           = "acctestWAS-230602030119199261"
  app_service_id = azurerm_linux_web_app.test.id

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
