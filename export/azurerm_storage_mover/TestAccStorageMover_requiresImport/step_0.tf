
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231020041957017107"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231020041957017107"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
