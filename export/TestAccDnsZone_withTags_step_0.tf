
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520053936366034"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220520053936366034.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
