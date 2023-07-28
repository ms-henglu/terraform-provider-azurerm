
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230728030536015380"
  location = "westus3"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230728030536015380"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
