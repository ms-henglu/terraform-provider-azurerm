
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021101095379"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-210910021101095379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_service_plan" "test2" {
  name                = "acctestASP2-210910021101095379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-210910021101095379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test2.id

  site_config {}
}

