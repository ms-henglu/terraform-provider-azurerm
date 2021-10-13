
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072253149834"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone211013072253149834.com"
  resource_group_name = azurerm_resource_group.test.name
}
