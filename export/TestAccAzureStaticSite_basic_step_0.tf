
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231557779984"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-220407231557779984"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}
