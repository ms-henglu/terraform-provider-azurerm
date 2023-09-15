
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023356241928"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230915023356241928.com"
  resource_group_name = azurerm_resource_group.test.name
}
