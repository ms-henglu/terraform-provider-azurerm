
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230721012531019869"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230721012531019869"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  description         = "Example Storage Mover Description"
  tags = {
    key = "value"
  }
}
