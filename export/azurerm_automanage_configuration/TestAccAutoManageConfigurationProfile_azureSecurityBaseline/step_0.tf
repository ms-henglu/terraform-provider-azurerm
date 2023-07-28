
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230728025109577330"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230728025109577330"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  azure_security_baseline {
    assignment_type = "ApplyAndAutoCorrect"
  }
}
