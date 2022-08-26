
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707291556"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707291556.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test2" {
  name                = "mypublicip2208260027072915562"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220826002707291556"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test2.id
}
