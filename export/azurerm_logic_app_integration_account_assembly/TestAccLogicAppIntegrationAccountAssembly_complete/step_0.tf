

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221117231108759258"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-221117231108759258"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_assembly" "test" {
  name                     = "acctest-assembly-221117231108759258"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  assembly_name            = "TestAssembly"
  assembly_version         = "1.1.1.1"
  content                  = filebase64("testdata/log4net.dll")

  metadata = {
    foo = "bar"
  }
}
