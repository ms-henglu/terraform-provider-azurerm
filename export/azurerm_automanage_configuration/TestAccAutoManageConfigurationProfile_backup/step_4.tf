
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112224001339542"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-240112224001339542"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
