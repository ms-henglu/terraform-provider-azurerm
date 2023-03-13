
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021143717645"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230313021143717645.com"
  resource_group_name = azurerm_resource_group.test.name
}
