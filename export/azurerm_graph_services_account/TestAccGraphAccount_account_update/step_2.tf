

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-240315123126646909"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap240315123126646909"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-240315123126646909"
  resource_group_name = azurerm_resource_group.test.name
  application_id      = "ARM_CLIENT_ID"
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
