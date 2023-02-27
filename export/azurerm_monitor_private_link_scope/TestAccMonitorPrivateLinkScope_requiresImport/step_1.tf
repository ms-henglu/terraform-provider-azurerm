


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-230227175738869665"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-ampls-230227175738869665"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_monitor_private_link_scope" "import" {
  name                = azurerm_monitor_private_link_scope.test.name
  resource_group_name = azurerm_monitor_private_link_scope.test.resource_group_name
}
