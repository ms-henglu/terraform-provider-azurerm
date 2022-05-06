
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506005717140762"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220506005717140762.com"
  resource_group_name = azurerm_resource_group.test.name
}
