
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230227033449387326"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                  = "acctest-sc-230227033449387326"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  sku_name              = "E0"
  build_agent_pool_size = "S2"
}
