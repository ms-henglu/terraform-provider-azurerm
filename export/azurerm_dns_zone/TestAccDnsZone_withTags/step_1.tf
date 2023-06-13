
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071824923366"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230613071824923366.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
