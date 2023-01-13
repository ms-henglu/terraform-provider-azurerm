
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230113181736338005"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                  = "acctest-sc-230113181736338005"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  sku_name              = "E0"
  build_agent_pool_size = "S2"
}
