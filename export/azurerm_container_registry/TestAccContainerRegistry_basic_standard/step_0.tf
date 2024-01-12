
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240112034116506521"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240112034116506521"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
