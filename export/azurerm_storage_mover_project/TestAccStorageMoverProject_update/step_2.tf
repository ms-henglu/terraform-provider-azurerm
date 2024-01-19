
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025926891539"
  location = "West Europe"
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-240119025926891539"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_project" "test" {
  name             = "acctest-sp-240119025926891539"
  storage_mover_id = azurerm_storage_mover.test.id
  description      = "Update example Project Description"
}
