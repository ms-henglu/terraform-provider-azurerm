
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045712376960"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230428045712376960.com"
  resource_group_name = azurerm_resource_group.test.name
}
