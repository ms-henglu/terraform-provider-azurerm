
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221512824235"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230316221512824235.com"
  resource_group_name = azurerm_resource_group.test.name
}
