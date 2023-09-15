
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915024313874176"
  location = "West Europe"
}
resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230915024313874176"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_source_endpoint" "test" {
  name             = "acctest-smse-230915024313874176"
  storage_mover_id = azurerm_storage_mover.test.id
  host             = "192.168.0.1"
  nfs_version      = "NFSv4"
  export           = "/"
  description      = "Update example Storage Container Endpoint Description"
}
