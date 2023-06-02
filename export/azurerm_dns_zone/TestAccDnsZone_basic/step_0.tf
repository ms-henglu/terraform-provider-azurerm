
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030504687088"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230602030504687088.com"
  resource_group_name = azurerm_resource_group.test.name
}
