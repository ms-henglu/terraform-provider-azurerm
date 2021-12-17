
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035243736911"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211217035243736911.com"
  resource_group_name = azurerm_resource_group.test.name
}
