
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230721014802793601"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230721014802793601"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
