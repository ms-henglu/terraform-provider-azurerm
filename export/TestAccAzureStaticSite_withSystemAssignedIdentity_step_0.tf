
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031248902691"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-220415031248902691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"

  identity {
    type = "SystemAssigned"
  }
}
