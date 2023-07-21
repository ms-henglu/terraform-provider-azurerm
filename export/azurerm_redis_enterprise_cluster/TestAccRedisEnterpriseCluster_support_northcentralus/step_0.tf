
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230721015908046800"
  location = "northcentralus"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230721015908046800"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
