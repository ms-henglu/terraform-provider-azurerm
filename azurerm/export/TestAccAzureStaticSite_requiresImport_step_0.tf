
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627123144800616"
  location = "West Europe"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-220627123144800616"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}
