
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001782671"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001782671.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ns_record" "test" {
  name                = "mynsrecord240119025001782671"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  records = ["ns1.contoso.com", "ns2.contoso.com"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
