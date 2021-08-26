
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023341571591"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone210826023341571591.com"
  resource_group_name = azurerm_resource_group.test.name
}
