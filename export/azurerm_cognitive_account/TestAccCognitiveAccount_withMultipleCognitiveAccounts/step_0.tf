
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230106034206200650"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-230106034206200650"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CustomVision.Prediction"
  sku_name            = "S0"
}

resource "azurerm_cognitive_account" "test2" {
  name                = "acctestcogacc2-230106034206200650"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CustomVision.Training"
  sku_name            = "S0"
}
