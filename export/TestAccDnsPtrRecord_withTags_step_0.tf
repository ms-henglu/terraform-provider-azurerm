
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011430881000"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220916011430881000.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ptr_record" "test" {
  name                = "testptrrecord220916011430881000"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["hashicorp.com", "microsoft.com"]

  tags = {
    environment = "Dev"
    cost_center = "Ops"
  }
}
