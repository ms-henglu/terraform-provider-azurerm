

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220826002929924826"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-220826002929924826"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_batch_configuration" "test" {
  name                     = "acctestiabcgadl3"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  batch_group_name         = "TestBatchGroup"

  release_criteria {
    message_count = 80
  }
}
