
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014126570236"
  location = "West Europe"
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-221111014126570236"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  redis_configuration {
  }

  tags = {
    environment = "production"
  }
}
