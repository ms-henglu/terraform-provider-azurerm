
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfm-211015015143008808"
  location = "West Europe"
}

resource "azurerm_service_fabric_mesh_secret" "test" {
  name                = "accTest-211015015143008808"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  content_type        = "string"

  description = "Test Description"
}
