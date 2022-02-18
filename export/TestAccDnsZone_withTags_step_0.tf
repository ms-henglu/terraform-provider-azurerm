
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218070732082680"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220218070732082680.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
