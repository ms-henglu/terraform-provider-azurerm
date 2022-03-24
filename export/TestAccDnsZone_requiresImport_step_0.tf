
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163320421739"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220324163320421739.com"
  resource_group_name = azurerm_resource_group.test.name
}
