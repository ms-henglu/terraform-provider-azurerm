
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-221221203936562684"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-221221203936562684"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "S1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-221221203936562684"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_app_service_source_control" "test" {
  app_id        = azurerm_windows_web_app.test.id
  use_local_git = true
}
