

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112033956428348"
  location = "West US 2"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-240112033956428348"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-240112033956428348"
  cognitive_account_id = azurerm_cognitive_account.test.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "2"
  }
  scale {
    type = "Standard"
  }
  rai_policy_name        = "RAI policy"
  version_upgrade_option = "OnceNewDefaultVersionAvailable"
}
