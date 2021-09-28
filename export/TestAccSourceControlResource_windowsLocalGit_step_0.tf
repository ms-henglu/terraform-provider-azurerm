
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-210928055136000610"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASSC-210928055136000610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-210928055136000610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_app_service_plan.test.id

  site_config {}
}



resource "azurerm_app_service_source_control" "test" {
  app_id        = azurerm_windows_web_app.test.id
  use_local_git = true
}

