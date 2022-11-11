
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517871559"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517871559.com"
  resource_group_name = azurerm_resource_group.test.name
}
