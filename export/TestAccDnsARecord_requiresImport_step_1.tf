

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729032706121923"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220729032706121923.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220729032706121923"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}


resource "azurerm_dns_a_record" "import" {
  name                = azurerm_dns_a_record.test.name
  resource_group_name = azurerm_dns_a_record.test.resource_group_name
  zone_name           = azurerm_dns_a_record.test.zone_name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
