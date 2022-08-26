
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatedns-220826003148795311"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220826003148795311.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
