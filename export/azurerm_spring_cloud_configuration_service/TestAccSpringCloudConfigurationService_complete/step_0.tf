

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843895514"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843895514"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_configuration_service" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  repository {
    name                     = "fake"
    label                    = "master"
    patterns                 = ["app/dev"]
    uri                      = "https://github.com/Azure-Samples/piggymetrics"
    search_paths             = ["dir1", "dir2"]
    strict_host_key_checking = false
    username                 = "adminuser"
    password                 = "H@Sh1CoR3!"
  }
}
