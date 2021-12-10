
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024305455546"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-211210024305455546"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-211210024305455546"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      java_version        = "java11"
      java_server         = "TOMCAT"
      java_server_version = "8.5"
    }
  }
}
