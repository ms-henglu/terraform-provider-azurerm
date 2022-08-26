
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707298519"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707298519.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord220826002707298519"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}
