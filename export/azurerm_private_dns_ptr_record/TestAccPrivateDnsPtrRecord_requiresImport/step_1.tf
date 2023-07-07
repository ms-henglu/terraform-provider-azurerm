

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004554670445"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "230707004554670445.0.10.in-addr.arpa"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_ptr_record" "test" {
  name                = "230707004554670445"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["test.contoso.com", "test2.contoso.com"]
}


resource "azurerm_private_dns_ptr_record" "import" {
  name                = azurerm_private_dns_ptr_record.test.name
  resource_group_name = azurerm_private_dns_ptr_record.test.resource_group_name
  zone_name           = azurerm_private_dns_ptr_record.test.zone_name
  ttl                 = 300
  records             = ["test.contoso.com", "test2.contoso.com"]
}
