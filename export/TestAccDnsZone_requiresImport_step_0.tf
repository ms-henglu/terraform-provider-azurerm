
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015546698930"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211029015546698930.com"
  resource_group_name = azurerm_resource_group.test.name
}
