
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230728031805499961"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230728031805499961"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
