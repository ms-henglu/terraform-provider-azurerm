
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517878477"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517878477.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
