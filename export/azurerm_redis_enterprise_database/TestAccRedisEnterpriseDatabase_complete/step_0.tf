

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-231016034614976598"
  location = "eastus"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-231016034614976598"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test1" {
  name                = "acctest-rec-231016034614976598"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test2" {
  name                = "acctest-rec-231016034614976598"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}


resource "azurerm_redis_enterprise_database" "test" {
  resource_group_name = azurerm_resource_group.test.name
  cluster_id          = azurerm_redis_enterprise_cluster.test.id

  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster"
  eviction_policy   = "NoEviction"

  module {
    name = "RediSearch"
    args = ""
  }

  module {
    name = "RedisBloom"
    args = "ERROR_RATE 1 INITIAL_SIZE 400"
  }

  module {
    name = "RedisTimeSeries"
    args = "RETENTION_POLICY 20"
  }

  module {
    name = "RedisJSON"
    args = ""
  }

  port = 10000
}
