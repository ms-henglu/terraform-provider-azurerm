
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022001939396643"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211022001939396643.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
