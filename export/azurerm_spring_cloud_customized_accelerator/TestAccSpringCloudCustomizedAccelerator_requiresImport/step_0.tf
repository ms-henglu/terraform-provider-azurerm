

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230616075509609261"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230616075509609261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_accelerator" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_customized_accelerator" "test" {
  name                        = "acctest-ca-230616075509609261"
  spring_cloud_accelerator_id = azurerm_spring_cloud_accelerator.test.id
  git_repository {
    url    = "https://github.com/Azure-Samples/piggymetrics"
    branch = "master"
  }
}
