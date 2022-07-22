
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035242955527"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220722035242955527.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
