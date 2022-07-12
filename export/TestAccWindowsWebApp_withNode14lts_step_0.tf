
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712041934685648"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-220712041934685648"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-220712041934685648"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      node_version  = "14-LTS"
      current_stack = "node"
    }
  }
}
