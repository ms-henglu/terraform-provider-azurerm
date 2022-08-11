
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053233366111"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220811053233366111.com"
  resource_group_name = azurerm_resource_group.test.name
}
