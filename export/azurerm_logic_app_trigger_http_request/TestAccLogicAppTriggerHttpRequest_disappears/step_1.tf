
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204504506950"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221221204504506950"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
