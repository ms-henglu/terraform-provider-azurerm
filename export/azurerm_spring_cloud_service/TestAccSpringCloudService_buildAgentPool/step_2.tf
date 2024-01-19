
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843907257"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                  = "acctest-sc-240119025843907257"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  sku_name              = "E0"
  build_agent_pool_size = "S2"
}
