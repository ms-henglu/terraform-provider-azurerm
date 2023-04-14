
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414021256384182"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230414021256384182.com"
  resource_group_name = azurerm_resource_group.test.name
}
