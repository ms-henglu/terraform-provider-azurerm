
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001780577"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001780577.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord240119025001780577"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.co.uk"
}
