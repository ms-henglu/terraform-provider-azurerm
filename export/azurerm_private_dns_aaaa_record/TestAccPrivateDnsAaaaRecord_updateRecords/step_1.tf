
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025637535489"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone240119025637535489.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_aaaa_record" "test" {
  name                = "myaaaarecord240119025637535489"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["fd5d:70bc:930e:d008:0000:0000:0000:7334", "fd5d:70bc:930e:d008::7335", "fd73:5e76:3ab5:d2e9::1"]
}
