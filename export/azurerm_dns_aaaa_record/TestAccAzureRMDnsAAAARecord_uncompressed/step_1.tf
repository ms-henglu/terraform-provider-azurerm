
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001777088"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001777088.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myarecord240119025001777088"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["2607:f8b0:4005:0800:0000:0000:0000:1003", "2201:1234:1234::1"]
}
