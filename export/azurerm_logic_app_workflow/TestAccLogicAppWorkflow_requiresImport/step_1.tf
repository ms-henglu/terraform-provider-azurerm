

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240119025300929968"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240119025300929968"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_workflow" "import" {
  name                = azurerm_logic_app_workflow.test.name
  location            = azurerm_logic_app_workflow.test.location
  resource_group_name = azurerm_logic_app_workflow.test.resource_group_name
}
