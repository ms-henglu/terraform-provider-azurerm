
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012153512242"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220916012153512242"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }

  reserved = true
}
