


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-221124182351135013"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-221124182351135013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-221124182351135013"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_build_deployment" "test" {
  name                = "acctest-scjd0v7d2"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  build_result_id     = "<default>"
}


resource "azurerm_spring_cloud_build_deployment" "import" {
  name                = azurerm_spring_cloud_build_deployment.test.name
  spring_cloud_app_id = azurerm_spring_cloud_build_deployment.test.spring_cloud_app_id
  build_result_id     = "<default>"
}
