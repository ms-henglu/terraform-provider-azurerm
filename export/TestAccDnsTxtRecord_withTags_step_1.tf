
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014612586218"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211015014612586218.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_txt_record" "test" {
  name                = "myarecord211015014612586218"
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
    environment = "staging"
  }
}
