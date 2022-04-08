
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051239105698"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220408051239105698.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
