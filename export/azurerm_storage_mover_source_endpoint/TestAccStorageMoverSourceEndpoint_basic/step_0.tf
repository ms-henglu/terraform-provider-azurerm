

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025926897296"
  location = "West Europe"
}
resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-240119025926897296"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_source_endpoint" "test" {
  name             = "acctest-smse-240119025926897296"
  storage_mover_id = azurerm_storage_mover.test.id
  host             = "192.168.0.1"
}
