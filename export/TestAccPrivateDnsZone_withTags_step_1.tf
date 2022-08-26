
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003148790539"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220826003148790539.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
