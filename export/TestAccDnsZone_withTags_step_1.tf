
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060025157128"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220204060025157128.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
