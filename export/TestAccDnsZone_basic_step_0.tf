
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630210803056219"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220630210803056219.com"
  resource_group_name = azurerm_resource_group.test.name
}
