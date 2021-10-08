
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044824540943"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone211008044824540943.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_aaaa_record" "test" {
  name                = "myaaaarecord211008044824540943"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["fd5d:70bc:930e:d008:0000:0000:0000:7334", "fd5d:70bc:930e:d008::7335"]

  tags = {
    environment = "staging"
  }
}
