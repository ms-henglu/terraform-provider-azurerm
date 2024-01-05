

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063230933443"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240105063230933443"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240105063230933443"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app" "import" {
  name                = azurerm_windows_web_app.test.name
  location            = azurerm_windows_web_app.test.location
  resource_group_name = azurerm_windows_web_app.test.resource_group_name
  service_plan_id     = azurerm_windows_web_app.test.service_plan_id

  site_config {}
}
