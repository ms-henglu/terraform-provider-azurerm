
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707295157"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707295157.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ptr_record" "test" {
  name                = "testptrrecord220826002707295157"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["hashicorp.com", "microsoft.com", "reddit.com"]
}
