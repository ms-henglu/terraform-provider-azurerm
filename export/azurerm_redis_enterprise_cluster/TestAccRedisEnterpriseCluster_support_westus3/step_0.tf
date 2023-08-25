
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-230825025206260398"
  location = "westus3"
}

resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-230825025206260398"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Enterprise_E100-2"
}
