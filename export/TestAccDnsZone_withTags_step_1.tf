
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042239382942"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220712042239382942.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
