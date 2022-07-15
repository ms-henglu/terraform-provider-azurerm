
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004418865842"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220715004418865842.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
