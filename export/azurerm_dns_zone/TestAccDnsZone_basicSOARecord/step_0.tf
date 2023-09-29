
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-230929064847636110"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230929064847636110.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
