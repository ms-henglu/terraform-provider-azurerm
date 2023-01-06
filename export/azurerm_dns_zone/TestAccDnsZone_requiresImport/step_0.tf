
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031426598317"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230106031426598317.com"
  resource_group_name = azurerm_resource_group.test.name
}
