

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-221111014134800924"
  location = "eastus"
}


resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-221111014134800924"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
