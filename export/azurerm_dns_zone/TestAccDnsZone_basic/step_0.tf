
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003851197110"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230707003851197110.com"
  resource_group_name = azurerm_resource_group.test.name
}
