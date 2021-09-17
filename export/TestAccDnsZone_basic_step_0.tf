
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031643286966"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone210917031643286966.com"
  resource_group_name = azurerm_resource_group.test.name
}
