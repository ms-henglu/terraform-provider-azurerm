
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032450120544"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220311032450120544.com"
  resource_group_name = azurerm_resource_group.test.name
}
