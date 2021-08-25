


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-210825043011299674"
  location = "West Europe"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-210825043011299674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestvault210825043074"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa210825043011274"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW2108250430112996"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_machine_learning_compute_instance" "test" {
  name                          = "acctest21082574"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  virtual_machine_size          = "STANDARD_DS2_V2"
}


resource "azurerm_machine_learning_compute_instance" "import" {
  name                          = azurerm_machine_learning_compute_instance.test.name
  location                      = azurerm_machine_learning_compute_instance.test.location
  machine_learning_workspace_id = azurerm_machine_learning_compute_instance.test.machine_learning_workspace_id
  virtual_machine_size          = "STANDARD_DS2_V2"
}
