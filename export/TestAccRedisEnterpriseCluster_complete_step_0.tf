

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-210928055835296016"
  location = "eastus"
}


resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-210928055835296016"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  minimum_tls_version = "1.2"

  sku_name = "EnterpriseFlash_F300-3"
  zones    = ["1", "2", "3"]

  tags = {
    ENV = "Test"
  }
}
