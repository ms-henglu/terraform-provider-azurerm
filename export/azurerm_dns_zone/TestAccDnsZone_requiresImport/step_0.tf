
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063327447596"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230203063327447596.com"
  resource_group_name = azurerm_resource_group.test.name
}
