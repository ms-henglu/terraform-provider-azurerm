
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117230845522652"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221117230845522652.com"
  resource_group_name = azurerm_resource_group.test.name
}
