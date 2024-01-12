


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223909050085"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-240112223909050085"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240112223909050085"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-240112223909050085"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "import" {
  name           = azurerm_windows_web_app_slot.test.name
  app_service_id = azurerm_windows_web_app_slot.test.app_service_id

  site_config {}

}
