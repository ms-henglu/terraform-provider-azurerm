



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230106031209903944"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-230106031209903944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-230106031209903944"
  cognitive_account_id = azurerm_cognitive_account.test.id
  model {
    format  = "OpenAI"
    name    = "text-curie-001"
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
    name    = "text-curie-001"
    version = "1"
  }
  scale {
    type = "Standard"
  }
}
