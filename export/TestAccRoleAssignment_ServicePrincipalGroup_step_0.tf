
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211001020510401554"
}

resource "azurerm_role_assignment" "test" {
  name                 = "19408dcd-c855-4eb3-90fd-46712c92eea7"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
