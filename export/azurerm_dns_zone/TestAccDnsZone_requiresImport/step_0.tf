
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033137411292"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230630033137411292.com"
  resource_group_name = azurerm_resource_group.test.name
}
