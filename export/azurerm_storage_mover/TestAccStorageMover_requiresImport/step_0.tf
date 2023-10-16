
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034838337660"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231016034838337660"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
