


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-211001053915374723"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-211001053915374723"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvault211001053923"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa211001053915323"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW-2110010539153747"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_machine_learning_workspace" "import" {
  name                    = azurerm_machine_learning_workspace.test.name
  location                = azurerm_machine_learning_workspace.test.location
  resource_group_name     = azurerm_machine_learning_workspace.test.resource_group_name
  application_insights_id = azurerm_machine_learning_workspace.test.application_insights_id
  key_vault_id            = azurerm_machine_learning_workspace.test.key_vault_id
  storage_account_id      = azurerm_machine_learning_workspace.test.storage_account_id

  identity {
    type = "SystemAssigned"
  }
}
