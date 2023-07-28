
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025017405603"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230728025017405603"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_service_plan" "test2" {
  name                = "acctestASP2-230728025017405603"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230728025017405603"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test2.id

  site_config {}
}
