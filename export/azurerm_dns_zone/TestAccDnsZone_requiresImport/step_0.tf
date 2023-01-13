
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181059837175"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230113181059837175.com"
  resource_group_name = azurerm_resource_group.test.name
}
