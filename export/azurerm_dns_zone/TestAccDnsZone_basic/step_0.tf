
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015040428118"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230721015040428118.com"
  resource_group_name = azurerm_resource_group.test.name
}
