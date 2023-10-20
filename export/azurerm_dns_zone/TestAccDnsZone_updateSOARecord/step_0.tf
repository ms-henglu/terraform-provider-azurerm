
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041039296339"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231020041039296339.com"
  resource_group_name = azurerm_resource_group.test.name
}
