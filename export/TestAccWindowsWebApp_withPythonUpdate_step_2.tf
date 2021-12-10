
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024305478508"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-211210024305478508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-211210024305478508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      python_version = "2.7"
      current_stack  = "python"
    }
  }
}
