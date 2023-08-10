
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230810144336159172"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230810144336159172"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_storage_mover" "import" {
  name                = azurerm_storage_mover.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
