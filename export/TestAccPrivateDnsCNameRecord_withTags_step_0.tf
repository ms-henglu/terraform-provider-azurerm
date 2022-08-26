
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003148786974"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220826003148786974.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname220826003148786974"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
