


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090918771755"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230609090918771755"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_cognitive_account" "test" {
  name                = "acctest-cogacct-230609090918771755"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}


resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-dls-230609090918771755"
  location = "West US 2"
}

resource "azurerm_cognitive_account" "test2" {
  name                = "acctest-cogacct-230609090918771755"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}
