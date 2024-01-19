
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025706900719"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119025706900719"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-240119025706900719"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  subnet_id           = azurerm_subnet.test.id
  redis_configuration {
  }
}
