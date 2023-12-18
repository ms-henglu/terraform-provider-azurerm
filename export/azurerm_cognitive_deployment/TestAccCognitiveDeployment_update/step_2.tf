





provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231218071348526806"
  location = "West US 2"
}
resource "azurerm_cognitive_account" "test" {
  name                = "acctest-ca-231218071348526806"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "OpenAI"
  sku_name            = "S0"
}


resource "azurerm_cognitive_deployment" "test" {
  name                 = "acctest-cd-231218071348526806"
  cognitive_account_id = azurerm_cognitive_account.test.id
  rai_policy_name      = "Microsoft.Default"
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "2"
  }
  scale {
    type     = "Standard"
    capacity = 2
  }
}
