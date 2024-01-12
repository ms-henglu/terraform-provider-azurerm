

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-240112224534653650"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap240112224534653650"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-240112224534653650"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
