
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211021234824868628"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211021234824868628"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}
