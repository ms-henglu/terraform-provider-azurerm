
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044358264895"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211008044358264895.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test2" {
  name                = "mypublicip2110080443582648952"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv6"
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myaaaarecord211008044358264895"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test2.id
}
