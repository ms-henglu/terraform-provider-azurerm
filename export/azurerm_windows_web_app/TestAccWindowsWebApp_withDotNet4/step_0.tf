
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203936599846"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221221203936599846"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-221221203936599846"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      dotnet_version = "v4.0"
      current_stack  = "dotnet"
    }
  }
}
