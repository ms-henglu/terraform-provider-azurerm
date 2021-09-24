
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004459721412"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-210924004459721412"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
