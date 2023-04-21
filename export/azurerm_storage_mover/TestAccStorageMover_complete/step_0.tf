
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230421023023956345"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230421023023956345"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  description         = "Example Storage Mover Description"
  tags = {
    key = "value"
  }
}
