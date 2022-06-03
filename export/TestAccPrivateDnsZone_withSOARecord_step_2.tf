
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatedns-220603005209915506"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220603005209915506.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email        = "testemail.com"
    expire_time  = 2419200
    minimum_ttl  = 200
    refresh_time = 2600
    retry_time   = 200
    ttl          = 100

    tags = {
      ENv = "Test"
    }
  }
}
