

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033859730799"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231016033859730799.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ns_record" "test" {
  name                = "mynsrecord231016033859730799"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com"]
}


resource "azurerm_dns_ns_record" "import" {
  name                = azurerm_dns_ns_record.test.name
  resource_group_name = azurerm_dns_ns_record.test.resource_group_name
  zone_name           = azurerm_dns_ns_record.test.zone_name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com"]
}
