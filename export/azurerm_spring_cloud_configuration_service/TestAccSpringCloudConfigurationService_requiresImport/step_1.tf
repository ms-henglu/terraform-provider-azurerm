


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843887771"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843887771"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_configuration_service" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_configuration_service" "import" {
  name                    = azurerm_spring_cloud_configuration_service.test.name
  spring_cloud_service_id = azurerm_spring_cloud_configuration_service.test.spring_cloud_service_id
}
