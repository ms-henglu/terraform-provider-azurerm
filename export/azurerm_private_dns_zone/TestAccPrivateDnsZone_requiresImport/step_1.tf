

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091837001692"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone230609091837001692.com"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_private_dns_zone" "import" {
  name                = azurerm_private_dns_zone.test.name
  resource_group_name = azurerm_private_dns_zone.test.resource_group_name
}
