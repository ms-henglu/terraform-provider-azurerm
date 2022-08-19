

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-redisEnterprise-220819165624788392"
  location = "eastus"
}


resource "azurerm_redis_enterprise_cluster" "test" {
  name                = "acctest-rec-220819165624788392"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  minimum_tls_version = "1.2"

  sku_name = "EnterpriseFlash_F300-3"
  zones    = ["1", "2", "3"]

  tags = {
    ENV = "Test"
  }
}
