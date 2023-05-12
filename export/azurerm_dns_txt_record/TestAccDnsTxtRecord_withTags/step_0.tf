
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010644303030"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512010644303030.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_txt_record" "test" {
  name                = "myarecord230512010644303030"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    value = "Quick brown fox"
  }

  record {
    value = "Another test txt string"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
