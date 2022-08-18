
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235136609135"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220818235136609135.com"
  resource_group_name = azurerm_resource_group.test.name
}
