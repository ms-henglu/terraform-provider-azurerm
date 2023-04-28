
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045712378288"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230428045712378288.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
