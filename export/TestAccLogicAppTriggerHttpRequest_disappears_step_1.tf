
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051039904859"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211119051039904859"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
