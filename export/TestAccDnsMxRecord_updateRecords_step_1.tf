
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024556022594"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211210024556022594.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_mx_record" "test" {
  name                = "myarecord211210024556022594"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    preference = "10"
    exchange   = "mail1.contoso.com"
  }

  record {
    preference = "20"
    exchange   = "mail2.contoso.com"
  }

  record {
    preference = "50"
    exchange   = "mail3.contoso.com"
  }
}
