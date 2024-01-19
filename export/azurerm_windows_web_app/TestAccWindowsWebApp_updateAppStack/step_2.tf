
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021457910311"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119021457910311"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240119021457910311"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    application_stack {
      current_stack                = "java"
      java_version                 = "11"
      java_embedded_server_enabled = "true"
    }
  }
}
