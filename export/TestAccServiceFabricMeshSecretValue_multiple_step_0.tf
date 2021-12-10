
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfm-211210025100435121"
  location = "West Europe"
}

resource "azurerm_service_fabric_mesh_secret" "test" {
  name                = "211210025100435121"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  content_type        = "string"
}

resource "azurerm_service_fabric_mesh_secret_value" "test" {
  name                          = "accTest-211210025100435121"
  service_fabric_mesh_secret_id = azurerm_service_fabric_mesh_secret.test.id
  location                      = azurerm_resource_group.test.location
  value                         = "testValue"
}

resource "azurerm_service_fabric_mesh_secret_value" "test2" {
  name                          = "accTest2-211210025100435121"
  service_fabric_mesh_secret_id = azurerm_service_fabric_mesh_secret.test.id
  location                      = azurerm_resource_group.test.location
  value                         = "testValue2"
}
