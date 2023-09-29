

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230929064947047888"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230929064947047888"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-230929064947047888"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
