
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121045136637406"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-220121045136637406"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}
