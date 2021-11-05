
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105035851543082"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211105035851543082.com"
  resource_group_name = azurerm_resource_group.test.name
}
