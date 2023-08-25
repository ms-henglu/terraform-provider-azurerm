
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230825025206279239"
  location = "northcentralus"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230825025206279239"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
