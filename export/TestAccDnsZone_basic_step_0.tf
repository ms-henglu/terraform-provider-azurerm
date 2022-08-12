
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015041173564"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220812015041173564.com"
  resource_group_name = azurerm_resource_group.test.name
}
