
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033329325315"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329325315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-231016033329325315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  public_network_access_enabled = false

  site_config {}
}
