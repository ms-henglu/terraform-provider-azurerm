
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-221216014032298186"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone221216014032298186.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_mx_record" "test" {
  name                = "testaccmx221216014032298186"
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
    environment = "staging"
  }
}
