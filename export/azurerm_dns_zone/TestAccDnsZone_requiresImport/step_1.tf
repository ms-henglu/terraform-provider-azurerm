

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172117915645"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221028172117915645.com"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_dns_zone" "import" {
  name                = azurerm_dns_zone.test.name
  resource_group_name = azurerm_dns_zone.test.resource_group_name
}
