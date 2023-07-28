

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230728030815899297"
  location = "West Europe"
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230728030815899297"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_project" "test" {
  name             = "acctest-sp-230728030815899297"
  storage_mover_id = azurerm_storage_mover.test.id
}


resource "azurerm_storage_mover_project" "import" {
  name             = azurerm_storage_mover_project.test.name
  storage_mover_id = azurerm_storage_mover.test.id
}
