
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922055010798631"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230922055010798631"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
