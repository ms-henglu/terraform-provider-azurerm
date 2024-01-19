
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024436484480"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-240119024436484480"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-240119024436484480"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_linux_web_app_slot" "test" {
  name           = "acctestWAS-240119024436484480"
  app_service_id = azurerm_linux_web_app.test.id

  site_config {
    application_stack {
      php_version = "7.4"
    }
  }
}

