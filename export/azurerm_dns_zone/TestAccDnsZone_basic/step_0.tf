
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022128191630"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230421022128191630.com"
  resource_group_name = azurerm_resource_group.test.name
}
