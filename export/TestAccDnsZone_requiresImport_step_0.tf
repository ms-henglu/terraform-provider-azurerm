
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011430892958"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220916011430892958.com"
  resource_group_name = azurerm_resource_group.test.name
}
