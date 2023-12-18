
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071732216623"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231218071732216623.com"
  resource_group_name = azurerm_resource_group.test.name
}
