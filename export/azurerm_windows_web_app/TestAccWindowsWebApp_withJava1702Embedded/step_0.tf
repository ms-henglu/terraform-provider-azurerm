
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003409838149"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230512003409838149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230512003409838149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      current_stack                = "java"
      java_version                 = "17.0.2"
      java_embedded_server_enabled = "true"
    }
  }
}
