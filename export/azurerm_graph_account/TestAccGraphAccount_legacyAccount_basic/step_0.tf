

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230915023456952649"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230915023456952649"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-230915023456952649"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
