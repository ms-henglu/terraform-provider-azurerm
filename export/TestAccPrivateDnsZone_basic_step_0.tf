
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011904849657"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220916011904849657.com"
  resource_group_name = azurerm_resource_group.test.name
}
