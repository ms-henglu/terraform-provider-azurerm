
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061103898914"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230922061103898914.com"
  resource_group_name = azurerm_resource_group.test.name
}
