
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020223200840"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-211112020223200840"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-211112020223200840"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      current_stack = "java"
      java_version  = "1.7"
      java_container = "JAVA"
      java_container_version = "9.3"
    }
  }
}

