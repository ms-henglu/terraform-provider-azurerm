
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060536079589"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230922060536079589"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230922060536079589"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    auto_heal_enabled = true

    auto_heal_setting {
      trigger {
        status_code {
          count             = 4
          interval          = "00:10:00"
          status_code_range = "403"
        }
        status_code {
          count             = 4
          interval          = "00:20:00"
          status_code_range = "500-599"
        }
        status_code {
          count             = 4
          interval          = "00:12:00"
          status_code_range = "400-401"
        }
      }
      action {
        action_type = "Recycle"
      }
    }
  }
}
