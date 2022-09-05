
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905045823265017"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220905045823265017.com"
  resource_group_name = azurerm_resource_group.test.name
}
