


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230915023656656839"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230915023656656839"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_batch_configuration" "test" {
  name                     = "acctestiabcpotpc"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  batch_group_name         = "TestBatchGroup"

  release_criteria {
    message_count = 80
  }
}


resource "azurerm_logic_app_integration_account_batch_configuration" "import" {
  name                     = azurerm_logic_app_integration_account_batch_configuration.test.name
  resource_group_name      = azurerm_logic_app_integration_account_batch_configuration.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_batch_configuration.test.integration_account_name
  batch_group_name         = azurerm_logic_app_integration_account_batch_configuration.test.batch_group_name

  release_criteria {
    message_count = azurerm_logic_app_integration_account_batch_configuration.test.release_criteria.0.message_count
  }
}
