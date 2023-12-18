

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-231218072440312566"
  location = "eastus"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-231218072440312566"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test1" {
  name                = "acctest-rec-231218072440312566"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}
resource "azurerm_redis_enterprise_cluster" "test2" {
  name                = "acctest-rec-231218072440312566"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E20-4"
}


resource "azurerm_redis_enterprise_database" "test" {
  name                = "default"
  resource_group_name = azurerm_resource_group.test.name
  cluster_id          = azurerm_redis_enterprise_cluster.test.id
}
