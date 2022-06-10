
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022536008178"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220610022536008178.com"
  resource_group_name = azurerm_resource_group.test.name
}
