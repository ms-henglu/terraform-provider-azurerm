

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013506187534"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221216013506187534.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord221216013506187534"
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
