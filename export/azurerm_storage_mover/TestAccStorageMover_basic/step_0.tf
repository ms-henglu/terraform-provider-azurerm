
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231218072652803186"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231218072652803186"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
