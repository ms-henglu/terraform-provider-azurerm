
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517866074"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517866074.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test2" {
  name                = "mypublicip2211110135178660742"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv6"
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myaaaarecord221111013517866074"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test2.id
}
