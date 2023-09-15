

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023356236069"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230915023356236069.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_srv_record" "test" {
  name                = "myarecord230915023356236069"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }

  record {
    priority = 2
    weight   = 25
    port     = 8080
    target   = "target2.contoso.com"
  }
}


resource "azurerm_dns_srv_record" "import" {
  name                = azurerm_dns_srv_record.test.name
  resource_group_name = azurerm_dns_srv_record.test.resource_group_name
  zone_name           = azurerm_dns_srv_record.test.zone_name
  ttl                 = 300

  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }

  record {
    priority = 2
    weight   = 25
    port     = 8080
    target   = "target2.contoso.com"
  }
}
