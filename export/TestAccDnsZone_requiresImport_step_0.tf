
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020744662843"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211001020744662843.com"
  resource_group_name = azurerm_resource_group.test.name
}
