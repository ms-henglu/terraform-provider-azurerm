


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230929064744487757"
  location = "West Europe"
}


resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-230929064744487757"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_data_protection_resource_guard" "import" {
  name                = azurerm_data_protection_resource_guard.test.name
  resource_group_name = azurerm_data_protection_resource_guard.test.resource_group_name
  location            = azurerm_data_protection_resource_guard.test.location
}
