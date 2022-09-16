
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011430885965"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220916011430885965.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test2" {
  name                = "mypublicip2209160114308859652"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220916011430885965"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test2.id
}
