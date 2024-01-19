
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025720599025"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-240119025720599025"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"

  tags = {
    Hello = "World"
  }
}
