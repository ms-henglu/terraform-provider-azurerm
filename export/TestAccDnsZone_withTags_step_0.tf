
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125048136289"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220124125048136289.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
