
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005930498459"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-230707005930498459"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-230707005930498459"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_linux_web_app_slot" "test" {
  name           = "acctestWAS-230707005930498459"
  app_service_id = azurerm_linux_web_app.test.id

  site_config {
    application_stack {
      java_version        = "11"
      java_server         = "TOMCAT"
      java_server_version = "8.5.61"
    }
  }
}

