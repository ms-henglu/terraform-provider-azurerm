
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210906022150092508"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF210906022150092508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
