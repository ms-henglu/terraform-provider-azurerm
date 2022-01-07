
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064021935032"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220107064021935032.com"
  resource_group_name = azurerm_resource_group.test.name
}
