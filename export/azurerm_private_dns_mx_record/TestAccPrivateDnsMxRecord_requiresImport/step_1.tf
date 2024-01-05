

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-240105061404083918"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone240105061404083918.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_mx_record" "test" {
  name                = "testaccmx240105061404083918"
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
}


resource "azurerm_private_dns_mx_record" "import" {
  name                = azurerm_private_dns_mx_record.test.name
  resource_group_name = azurerm_private_dns_mx_record.test.resource_group_name
  zone_name           = azurerm_private_dns_mx_record.test.zone_name
  ttl                 = 300
  record {
    preference = 10
    exchange   = "mx1.contoso.com"
  }
  record {
    preference = 10
    exchange   = "mx2.contoso.com"
  }
}
