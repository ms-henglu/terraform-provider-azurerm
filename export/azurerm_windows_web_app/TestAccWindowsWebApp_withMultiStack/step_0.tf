
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035132849442"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221202035132849442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-221202035132849442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      dotnet_version         = "v4.0"
      php_version            = "7.4"
      python_version         = "3.4.0"
      java_version           = "1.8"
      java_container         = "TOMCAT"
      java_container_version = "9.0"
    }
  }
}
