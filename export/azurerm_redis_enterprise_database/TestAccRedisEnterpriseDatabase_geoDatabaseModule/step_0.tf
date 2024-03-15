

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-240315123926797619"
  location = "eastus"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-240315123926797619"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test1" {
  name                = "acctest-rec-240315123926797619"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test2" {
  name                = "acctest-rec-240315123926797619"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}

resource "azurerm_redis_enterprise_database" "test" {
  cluster_id          = azurerm_redis_enterprise_cluster.test.id
  resource_group_name = azurerm_resource_group.test.name

  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster"
  eviction_policy   = "NoEviction"
  module {
    name = "RediSearch"
    args = ""
  }
  linked_database_id = [
    "${azurerm_redis_enterprise_cluster.test.id}/databases/default",
    "${azurerm_redis_enterprise_cluster.test1.id}/databases/default",
    "${azurerm_redis_enterprise_cluster.test2.id}/databases/default"
  ]

  linked_database_group_nickname = "tftestGeoGroup"
}
