
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010644319830"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512010644319830.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
