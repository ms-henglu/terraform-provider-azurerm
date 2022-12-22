
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034629654562"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221222034629654562.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
