
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020744667129"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211001020744667129.com"
  resource_group_name = azurerm_resource_group.test.name
}
