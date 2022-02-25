
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034400385952"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220225034400385952.com"
  resource_group_name = azurerm_resource_group.test.name
}
