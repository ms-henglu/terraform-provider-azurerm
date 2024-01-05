
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061154790486"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240105061154790486"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
