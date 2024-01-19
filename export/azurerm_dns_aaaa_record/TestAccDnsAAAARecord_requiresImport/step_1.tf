

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001772928"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001772928.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myarecord240119025001772928"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["2607:f8b0:4009:1803::1005", "2607:f8b0:4009:1803::1006"]
}


resource "azurerm_dns_aaaa_record" "import" {
  name                = azurerm_dns_aaaa_record.test.name
  resource_group_name = azurerm_dns_aaaa_record.test.resource_group_name
  zone_name           = azurerm_dns_aaaa_record.test.zone_name
  ttl                 = 300
  records             = ["2607:f8b0:4009:1803::1005", "2607:f8b0:4009:1803::1006"]
}
