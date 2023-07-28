
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230728025109574443"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230728025109574443"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  antimalware {
    exclusions {
      extensions = "exe;dll"
    }
    real_time_protection_enabled = true
  }
  automation_account_enabled = true
}


resource "azurerm_automanage_configuration" "import" {
  name                = azurerm_automanage_configuration.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
