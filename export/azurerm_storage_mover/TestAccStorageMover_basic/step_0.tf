
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230505051410273163"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230505051410273163"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
