
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517868467"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517868467.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myarecord221111013517868467"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["3a62:353:8885:293c:a218:45cc:9ee9:4e27", "3a62:353:8885:293c:a218:45cc:9ee9:4e28"]
}
