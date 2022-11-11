
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517875211"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517875211.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ns_record" "test" {
  name                = "mynsrecord221111013517875211"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com", "ns3.contoso.com"]
}
