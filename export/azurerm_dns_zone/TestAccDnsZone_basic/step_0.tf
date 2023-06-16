
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074719080517"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230616074719080517.com"
  resource_group_name = azurerm_resource_group.test.name
}
