
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023341573506"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone210826023341573506.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
