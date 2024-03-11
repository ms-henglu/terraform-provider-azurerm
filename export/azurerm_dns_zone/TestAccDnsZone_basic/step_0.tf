
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032021295213"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240311032021295213.com"
  resource_group_name = azurerm_resource_group.test.name
}
