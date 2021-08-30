

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-210830084145381049"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-210830084145381049"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvault210830084149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa210830084145349"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_container_registry" "test" {
  name                = "acctestacr2108300841453810"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW-2108300841453810"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  friendly_name           = "test-workspace-updated"
  description             = "Test machine learning workspace update"
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id
  container_registry_id   = azurerm_container_registry.test.id
  sku_name                = "Basic"
  high_business_impact    = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
    FOO = "Updated"
  }
}
