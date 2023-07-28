


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230728030037855651"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230728030037855651"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_assembly" "test" {
  name                     = "acctest-assembly-230728030037855651"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  assembly_name            = "TestAssembly"
  content                  = filebase64("testdata/log4net.dll")
}


resource "azurerm_logic_app_integration_account_assembly" "import" {
  name                     = azurerm_logic_app_integration_account_assembly.test.name
  resource_group_name      = azurerm_logic_app_integration_account_assembly.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_assembly.test.integration_account_name
  assembly_name            = azurerm_logic_app_integration_account_assembly.test.assembly_name
  content                  = azurerm_logic_app_integration_account_assembly.test.content
}
