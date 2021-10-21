
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021234956119582"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211021234956119582.com"
  resource_group_name = azurerm_resource_group.test.name
}
