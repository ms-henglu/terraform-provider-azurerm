


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240112035205064843"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240112035205064843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_dev_tool_portal" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_dev_tool_portal" "import" {
  name                    = azurerm_spring_cloud_dev_tool_portal.test.name
  spring_cloud_service_id = azurerm_spring_cloud_dev_tool_portal.test.spring_cloud_service_id
}
