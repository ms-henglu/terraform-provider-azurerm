
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071203489600"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231218071203489600"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


data "azurerm_client_config" "current" {}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestLWA-231218071203489600"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"
    active_directory_v2 {
      client_id = data.azurerm_client_config.current.client_id
      allowed_audiences = [
        "activedirectorytokenaudiences",
      ]
      tenant_auth_endpoint = "https://sts.windows.net/ARM_TENANT_ID/v2.0"
    }


    login {}
  }
}
