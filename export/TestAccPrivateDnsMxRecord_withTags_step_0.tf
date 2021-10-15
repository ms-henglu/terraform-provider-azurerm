
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-211015014646537249"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone211015014646537249.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_mx_record" "test" {
  name                = "testaccmx211015014646537249"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record {
    preference = 10
    exchange   = "mx1.contoso.com"
  }
  record {
    preference = 10
    exchange   = "mx2.contoso.com"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
