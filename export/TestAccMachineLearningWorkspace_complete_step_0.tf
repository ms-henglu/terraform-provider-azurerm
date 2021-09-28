

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-210928055621859989"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-210928055621859989"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvault210928055689"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa210928055621889"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_container_registry" "test" {
  name                = "acctestacr2109280556218599"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_machine_learning_workspace" "test" {
  name                          = "acctest-MLW-2109280556218599"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  friendly_name                 = "test-workspace"
  description                   = "Test machine learning workspace"
  application_insights_id       = azurerm_application_insights.test.id
  key_vault_id                  = azurerm_key_vault.test.id
  storage_account_id            = azurerm_storage_account.test.id
  container_registry_id         = azurerm_container_registry.test.id
  sku_name                      = "Basic"
  high_business_impact          = true
  public_network_access_enabled = true
  image_build_compute_name      = "terraformCompute"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}
