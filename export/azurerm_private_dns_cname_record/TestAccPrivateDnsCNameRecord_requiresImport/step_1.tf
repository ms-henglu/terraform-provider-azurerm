

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021730083562"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone230313021730083562.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname230313021730083562"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}


resource "azurerm_private_dns_cname_record" "import" {
  name                = azurerm_private_dns_cname_record.test.name
  resource_group_name = azurerm_private_dns_cname_record.test.resource_group_name
  zone_name           = azurerm_private_dns_cname_record.test.zone_name
  ttl                 = 300
  record              = "contoso.com"
}
