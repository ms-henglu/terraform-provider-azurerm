
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210906022106453465"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210906022106453465"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
