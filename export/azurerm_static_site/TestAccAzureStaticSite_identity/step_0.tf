
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707011121193911"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-230707011121193911"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"

  identity {
    type = "SystemAssigned"
  }
}
