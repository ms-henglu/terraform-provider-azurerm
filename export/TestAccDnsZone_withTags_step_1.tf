
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064125533011"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220114064125533011.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
