
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230707004853849392"
  location = "West Europe"
}


resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230707004853849392"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  description         = "Update Example Storage Mover Description"
  tags = {
    key = "value"
  }
}
