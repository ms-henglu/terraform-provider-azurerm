
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033329399787"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-231016033329399787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-231016033329399787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_service_plan" "test2" {
  name                = "acctestASP2-231016033329399787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_service_plan" "test3" {
  name                = "acctestASP3-231016033329399787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-231016033329399787"
  app_service_id = azurerm_windows_web_app.test.id

  service_plan_id = azurerm_service_plan.test3.id

  site_config {}
}
