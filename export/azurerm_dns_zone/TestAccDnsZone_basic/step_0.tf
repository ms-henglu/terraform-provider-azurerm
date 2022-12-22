
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034629652518"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221222034629652518.com"
  resource_group_name = azurerm_resource_group.test.name
}
