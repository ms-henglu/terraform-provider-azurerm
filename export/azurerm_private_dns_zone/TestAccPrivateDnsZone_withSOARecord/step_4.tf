
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatedns-230804030529995925"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone230804030529995925.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
