
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035132778264"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221202035132778264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}


resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-221202035132778264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      java_version        = "java8"
      java_server         = "JBOSSEAP"
      java_server_version = "7.3"
    }
  }
}
