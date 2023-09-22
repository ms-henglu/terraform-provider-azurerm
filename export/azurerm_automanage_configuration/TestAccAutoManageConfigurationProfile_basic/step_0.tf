
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922060631597714"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230922060631597714"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
