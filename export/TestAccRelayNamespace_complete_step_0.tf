
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011934367406"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-220916011934367406"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"

  tags = {
    Hello = "World"
  }
}
