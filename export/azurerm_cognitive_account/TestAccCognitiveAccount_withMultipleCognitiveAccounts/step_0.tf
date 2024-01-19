
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-240119024621914394"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-240119024621914394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CustomVision.Prediction"
  sku_name            = "S0"
}

resource "azurerm_cognitive_account" "test2" {
  name                = "acctestcogacc2-240119024621914394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CustomVision.Training"
  sku_name            = "S0"
}
