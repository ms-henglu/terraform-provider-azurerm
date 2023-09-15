
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022839965106"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230915022839965106"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230915022839965106"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      dotnet_core_version = "v4.0"
      current_stack       = "dotnetcore"
    }
  }
}
