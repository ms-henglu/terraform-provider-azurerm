

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230519075050181288"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230519075050181288"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_batch_configuration" "test" {
  name                     = "acctestiabc0pq7n"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  batch_group_name         = "TestBatchGroup"

  release_criteria {
    message_count = 80
  }
}
