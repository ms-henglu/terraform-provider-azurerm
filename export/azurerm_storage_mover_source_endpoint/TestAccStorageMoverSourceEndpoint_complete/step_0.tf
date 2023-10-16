
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034838335259"
  location = "West Europe"
}
resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231016034838335259"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_source_endpoint" "test" {
  name             = "acctest-smse-231016034838335259"
  storage_mover_id = azurerm_storage_mover.test.id
  export           = "/"
  host             = "192.168.0.1"
  nfs_version      = "NFSv4"
  description      = "Example Storage Container Endpoint Description"
}
