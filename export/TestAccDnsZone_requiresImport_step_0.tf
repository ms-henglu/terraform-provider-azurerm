
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020606531168"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211112020606531168.com"
  resource_group_name = azurerm_resource_group.test.name
}
