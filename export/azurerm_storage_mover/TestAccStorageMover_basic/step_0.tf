
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230407024237151035"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230407024237151035"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
