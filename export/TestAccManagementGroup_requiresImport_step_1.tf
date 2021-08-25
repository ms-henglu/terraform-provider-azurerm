
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_management_group" "import" {
  name = azurerm_management_group.test.name
}
