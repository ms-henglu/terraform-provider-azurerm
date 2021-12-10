
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025209217748"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-211210025209217748"
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
