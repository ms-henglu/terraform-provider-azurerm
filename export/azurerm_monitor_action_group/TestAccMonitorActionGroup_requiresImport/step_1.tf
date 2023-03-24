

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052437865009"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230324052437865009"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}


resource "azurerm_monitor_action_group" "import" {
  name                = azurerm_monitor_action_group.test.name
  resource_group_name = azurerm_monitor_action_group.test.resource_group_name
  short_name          = azurerm_monitor_action_group.test.short_name
}
