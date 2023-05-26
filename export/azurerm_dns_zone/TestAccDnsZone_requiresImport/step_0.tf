
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085052375239"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230526085052375239.com"
  resource_group_name = azurerm_resource_group.test.name
}
