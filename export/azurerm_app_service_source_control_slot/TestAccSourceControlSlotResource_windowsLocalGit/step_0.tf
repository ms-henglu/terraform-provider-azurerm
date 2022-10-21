
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-221021030829345045"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASSC-221021030829345045"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-221021030829345045"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_app_service_plan.test.id

  site_config {}
}

resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-221021030829345045"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}
}


resource "azurerm_app_service_source_control_slot" "test" {
  slot_id       = azurerm_windows_web_app_slot.test.id
  use_local_git = true
}
