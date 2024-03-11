


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031518948769"
  location = "West US 2"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-240311031518948769"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-240311031518948769"
  cognitive_account_id = azurerm_cognitive_account.test.id
  model {
    format = "OpenAI"
    name   = "text-embedding-ada-002"
  }
  scale {
    type = "Standard"
  }
  lifecycle {
    ignore_changes = [model.0.version]
  }
}


resource "azurerm_cognitive_deployment" "import" {
  name                 = azurerm_cognitive_deployment.test.name
  cognitive_account_id = azurerm_cognitive_account.test.id
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "2"
  }
  scale {
    type = "Standard"
  }
}
