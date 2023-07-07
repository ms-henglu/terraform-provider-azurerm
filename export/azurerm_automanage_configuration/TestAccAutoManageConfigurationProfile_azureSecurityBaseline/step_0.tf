
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230707003348973119"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230707003348973119"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  azure_security_baseline {
    assignment_type = "ApplyAndAutoCorrect"
  }
}
