
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204955191218"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-221221204955191218"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"

  tags = {
    environment = "acceptance"
    updated     = "true"
  }
}
