
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240119021808949269"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240119021808949269"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
