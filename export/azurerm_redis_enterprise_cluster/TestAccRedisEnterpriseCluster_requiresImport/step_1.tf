


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230728030536017574"
  location = "eastus"
}


resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230728030536017574"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}


resource "azurerm_redis_enterprise_cluster" "import" {
  name                = azurerm_redis_enterprise_cluster.test.name
  resource_group_name = azurerm_redis_enterprise_cluster.test.resource_group_name
  location            = azurerm_redis_enterprise_cluster.test.location

  sku_name = azurerm_redis_enterprise_cluster.test.sku_name
}
