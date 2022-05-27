

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220527034730220732"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220527034730220732"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-220527034730220732"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "acctest-scjdjbx4c"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  quota {
    cpu    = "2"
    memory = "4Gi"
  }
}
