
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071832418758"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211013071832418758.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
