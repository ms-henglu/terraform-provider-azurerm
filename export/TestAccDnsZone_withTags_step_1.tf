
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105035851543908"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211105035851543908.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
