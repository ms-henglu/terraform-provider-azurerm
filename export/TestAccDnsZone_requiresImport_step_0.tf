
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014800878075"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220726014800878075.com"
  resource_group_name = azurerm_resource_group.test.name
}
