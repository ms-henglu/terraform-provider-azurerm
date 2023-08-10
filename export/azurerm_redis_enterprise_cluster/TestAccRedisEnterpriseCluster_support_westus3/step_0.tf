
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230810144127098053"
  location = "westus3"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230810144127098053"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
