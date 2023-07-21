

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230721011725298257"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230721011725298257"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-230721011725298257"
  resource_group_name = azurerm_resource_group.test.name
  application_id      = "ARM_CLIENT_ID"
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
