
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034132465692"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220527034132465692.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
