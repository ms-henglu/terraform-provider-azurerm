
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034838331983"
  location = "West Europe"
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231016034838331983"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_project" "test" {
  name             = "acctest-sp-231016034838331983"
  storage_mover_id = azurerm_storage_mover.test.id
}
