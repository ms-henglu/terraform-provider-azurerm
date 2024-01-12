
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223909051945"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240112223909051945"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240112223909051945"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    auto_heal_enabled = true

    auto_heal_setting {
      trigger {
        status_code {
          count             = 1
          status_code_range = 500
          sub_status        = 37
          interval          = "00:01:00"
        }
        status_code {
          count             = 1
          status_code_range = 500
          sub_status        = 30
          win32_status_code = 0
          interval          = "00:10:00"
        }
      }
      action {
        action_type = "Recycle"
      }
    }
  }
}
