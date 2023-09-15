

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-230915023710415474"
  location = "West Europe"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230915023710415474"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                     = "acckv230915023710415474"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa230915023710474"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_machine_learning_workspace" "test" {
  name                          = "acctest-MLW2309150237104154"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  application_insights_id       = azurerm_application_insights.test.id
  key_vault_id                  = azurerm_key_vault.test.id
  storage_account_id            = azurerm_storage_account.test.id
  public_network_access_enabled = true
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_machine_learning_compute_instance" "test" {
  name                          = "acctest23091574"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  virtual_machine_size          = "STANDARD_DS2_V2"
  local_auth_enabled            = false
}
