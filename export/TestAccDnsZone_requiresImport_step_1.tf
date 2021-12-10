

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024556031767"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211210024556031767.com"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_dns_zone" "import" {
  name                = azurerm_dns_zone.test.name
  resource_group_name = azurerm_dns_zone.test.resource_group_name
}
