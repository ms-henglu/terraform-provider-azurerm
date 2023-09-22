




provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922060727403173"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-230922060727403173"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-230922060727403173"
  cognitive_account_id = azurerm_cognitive_account.test.id
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "1"
  }
  scale {
    type = "Standard"
  }
}


resource "azurerm_cognitive_deployment" "import" {
  name                 = azurerm_cognitive_deployment.test.name
  cognitive_account_id = azurerm_cognitive_account.test.id
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "1"
  }
  scale {
    type = "Standard"
  }
}
