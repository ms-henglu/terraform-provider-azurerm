
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082411714540"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220128082411714540.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
