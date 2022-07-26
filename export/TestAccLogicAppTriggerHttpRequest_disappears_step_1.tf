
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014959390900"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220726014959390900"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
