

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230728032345778510"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230728032345778510"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-230728032345778510"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
