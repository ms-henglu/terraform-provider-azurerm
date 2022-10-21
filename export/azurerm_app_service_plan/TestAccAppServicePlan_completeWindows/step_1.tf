
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034718485971"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-221021034718485971"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }

  per_site_scaling = true
  reserved         = false

  tags = {
    environment = "Test"
  }
}
