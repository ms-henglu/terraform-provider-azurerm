

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004554665766"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone230707004554665766.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname230707004554665766"
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
