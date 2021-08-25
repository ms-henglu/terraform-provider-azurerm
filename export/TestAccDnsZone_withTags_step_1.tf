
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044745719804"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone210825044745719804.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
