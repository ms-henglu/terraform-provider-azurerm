
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707295599"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707295599.com"
  resource_group_name = azurerm_resource_group.test.name
}
