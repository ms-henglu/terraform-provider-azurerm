
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033859739751"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231016033859739751.com"
  resource_group_name = azurerm_resource_group.test.name
}
