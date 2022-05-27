
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034132460046"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220527034132460046.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test" {
  name                = "mypublicip220527034132460046"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220527034132460046"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test.id
}
