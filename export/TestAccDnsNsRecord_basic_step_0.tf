
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034132467981"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220527034132467981.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ns_record" "test" {
  name                = "mynsrecord220527034132467981"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com"]
}
