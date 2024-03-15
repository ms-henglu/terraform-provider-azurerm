
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240315122339636605"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-240315122339636605"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
