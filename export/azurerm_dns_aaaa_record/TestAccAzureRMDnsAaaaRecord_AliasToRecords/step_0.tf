
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001775504"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001775504.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test" {
  name                = "mypublicip240119025001775504"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv6"
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myarecord240119025001775504"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test.id
}
