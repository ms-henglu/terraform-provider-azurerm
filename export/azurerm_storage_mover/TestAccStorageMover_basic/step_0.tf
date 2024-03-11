
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311033308674525"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-240311033308674525"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
