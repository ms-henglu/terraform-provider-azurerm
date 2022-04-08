
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051239103022"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220408051239103022.com"
  resource_group_name = azurerm_resource_group.test.name
}
