
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204718112153"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone221221204718112153.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname221221204718112153"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"

  tags = {
    environment = "staging"
  }
}
