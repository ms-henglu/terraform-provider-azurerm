
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034102286913"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221021034102286913.com"
  resource_group_name = azurerm_resource_group.test.name
}
