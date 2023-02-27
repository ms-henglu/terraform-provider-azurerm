
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227032648934280"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230227032648934280.com"
  resource_group_name = azurerm_resource_group.test.name
}
