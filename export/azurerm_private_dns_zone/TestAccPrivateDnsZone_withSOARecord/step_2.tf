
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatedns-230825025137709751"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone230825025137709751.com"
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
