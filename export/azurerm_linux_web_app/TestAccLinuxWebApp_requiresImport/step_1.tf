


provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122240582430"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240315122240582430"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-240315122240582430"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_linux_web_app" "import" {
  name                = azurerm_linux_web_app.test.name
  location            = azurerm_linux_web_app.test.location
  resource_group_name = azurerm_linux_web_app.test.resource_group_name
  service_plan_id     = azurerm_linux_web_app.test.service_plan_id

  site_config {}

}
