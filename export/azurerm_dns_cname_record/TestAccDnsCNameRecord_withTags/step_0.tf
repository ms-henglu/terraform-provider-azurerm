
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025910693351"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230804025910693351.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "test" {
  name                = "myarecord230804025910693351"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
