
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfm-211013072408295092"
  location = "West Europe"
}

resource "azurerm_service_fabric_mesh_secret" "test" {
  name                = "accTest-211013072408295092"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "Test Description"
  content_type        = "string"

  tags = {
    Hello = "World"
  }
}
