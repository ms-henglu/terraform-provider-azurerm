
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043424861985"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231013043424861985.com"
  resource_group_name = azurerm_resource_group.test.name
}
