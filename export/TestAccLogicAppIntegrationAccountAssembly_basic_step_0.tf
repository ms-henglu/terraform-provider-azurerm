

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220916011651453682"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-220916011651453682"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_assembly" "test" {
  name                     = "acctest-assembly-220916011651453682"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  assembly_name            = "TestAssembly"
  content                  = filebase64("testdata/log4net.dll")
}
