
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923011824760727"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220923011824760727.com"
  resource_group_name = azurerm_resource_group.test.name
}
