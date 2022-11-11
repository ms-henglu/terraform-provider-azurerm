
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014059058125"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone221111014059058125.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_aaaa_record" "test" {
  name                = "myaaaarecord221111014059058125"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["fd5d:70bc:930e:d008:0000:0000:0000:7334", "fd5d:70bc:930e:d008::7335"]

  tags = {
    environment = "staging"
  }
}
