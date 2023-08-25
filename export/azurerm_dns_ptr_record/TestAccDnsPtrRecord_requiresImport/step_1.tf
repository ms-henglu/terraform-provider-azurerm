

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024516903322"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230825024516903322.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ptr_record" "test" {
  name                = "testptrrecord230825024516903322"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["hashicorp.com", "microsoft.com"]
}


resource "azurerm_dns_ptr_record" "import" {
  name                = azurerm_dns_ptr_record.test.name
  resource_group_name = azurerm_dns_ptr_record.test.resource_group_name
  zone_name           = azurerm_dns_ptr_record.test.zone_name
  ttl                 = 300
  records             = ["hashicorp.com", "microsoft.com"]
}
