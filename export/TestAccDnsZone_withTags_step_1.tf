
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407230943791623"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220407230943791623.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
