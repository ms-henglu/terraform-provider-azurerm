
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520053936354399"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220520053936354399.com"
  resource_group_name = azurerm_resource_group.test.name
}
