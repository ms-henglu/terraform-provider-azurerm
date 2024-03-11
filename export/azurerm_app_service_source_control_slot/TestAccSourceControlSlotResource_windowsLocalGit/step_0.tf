
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-240311031305949055"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240311031305949055"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240311031305949055"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}

resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-240311031305949055"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}
}


resource "azurerm_app_service_source_control_slot" "test" {
  slot_id       = azurerm_windows_web_app_slot.test.id
  use_local_git = true
}
