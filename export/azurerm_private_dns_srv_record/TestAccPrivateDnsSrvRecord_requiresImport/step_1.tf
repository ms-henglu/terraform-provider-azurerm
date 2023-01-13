

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-230113181549622414"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone230113181549622414.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_srv_record" "test" {
  name                = "testaccsrv230113181549622414"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }

  record {
    priority = 10
    weight   = 10
    port     = 8080
    target   = "target2.contoso.com"
  }
}


resource "azurerm_private_dns_srv_record" "import" {
  name                = azurerm_private_dns_srv_record.test.name
  resource_group_name = azurerm_private_dns_srv_record.test.resource_group_name
  zone_name           = azurerm_private_dns_srv_record.test.zone_name
  ttl                 = 300
  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }
  record {
    priority = 10
    weight   = 10
    port     = 8080
    target   = "target2.contoso.com"
  }
}
