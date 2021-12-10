

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-211210024955555991"
  location = "eastus"
}


resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-211210024955555991"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
