
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014800879944"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220726014800879944.com"
  resource_group_name = azurerm_resource_group.test.name
}
