
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014059060120"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone221111014059060120.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
