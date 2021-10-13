
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071832407754"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211013071832407754.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ns_record" "test" {
  name                = "mynsrecord211013071832407754"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com"]
}
