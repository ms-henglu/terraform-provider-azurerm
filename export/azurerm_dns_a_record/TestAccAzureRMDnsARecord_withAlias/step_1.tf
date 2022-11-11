
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517864516"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517864516.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test2" {
  name                = "mypublicip2211110135178645162"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord221111013517864516"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.test2.id
}
