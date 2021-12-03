
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203013804290193"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211203013804290193.com"
  resource_group_name = azurerm_resource_group.test.name
}
