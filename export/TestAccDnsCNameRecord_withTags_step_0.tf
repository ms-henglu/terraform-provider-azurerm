
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071832407864"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211013071832407864.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord211013071832407864"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
