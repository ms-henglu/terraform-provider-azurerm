
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025405377206"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-230804025405377206"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230804025405377206"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-230804025405377206"
  app_service_id = azurerm_windows_web_app.test.id

  public_network_access_enabled = false

  site_config {}
}
