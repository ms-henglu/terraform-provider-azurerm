

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-231013043048298586"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-231013043048298586"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Face"
  sku_name            = "S0"
}


resource "azurerm_cognitive_account" "import" {
  name                = azurerm_cognitive_account.test.name
  location            = azurerm_cognitive_account.test.location
  resource_group_name = azurerm_cognitive_account.test.resource_group_name
  kind                = azurerm_cognitive_account.test.kind
  sku_name            = "S0"
}
