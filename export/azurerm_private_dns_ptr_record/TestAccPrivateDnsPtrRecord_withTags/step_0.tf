
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061746108102"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "230922061746108102.0.10.in-addr.arpa"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_ptr_record" "test" {
  name                = "230922061746108102"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["test.contoso.com", "test2.contoso.com"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
