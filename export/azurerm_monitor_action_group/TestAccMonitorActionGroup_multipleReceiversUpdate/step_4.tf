
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423963874"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240119025423963874"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
