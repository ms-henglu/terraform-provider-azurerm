

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221221204029084939"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-221221204029084939"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-221221204029084939"
  cognitive_account_id = azurerm_cognitive_account.test.id

  model {
    format  = "OpenAI"
    name    = "text-davinci-002"
    version = "1"
  }

  scale {
    type = "Standard"
  }

  rai_policy_name = "RAI policy"
}
