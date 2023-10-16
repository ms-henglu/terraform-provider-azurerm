
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016033421196070"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-231016033421196070"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
