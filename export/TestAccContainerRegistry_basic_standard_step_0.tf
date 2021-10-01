
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211001223813621631"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211001223813621631"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
