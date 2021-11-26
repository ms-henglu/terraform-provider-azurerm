
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031154757589"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211126031154757589.com"
  resource_group_name = azurerm_resource_group.test.name
}
