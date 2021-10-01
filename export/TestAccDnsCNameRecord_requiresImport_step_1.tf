

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001223952695157"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211001223952695157.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord211001223952695157"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}


resource "azurerm_dns_cname_record" "import" {
  name                = azurerm_dns_cname_record.test.name
  resource_group_name = azurerm_dns_cname_record.test.resource_group_name
  zone_name           = azurerm_dns_cname_record.test.zone_name
  ttl                 = 300
  record              = "contoso.com"
}
