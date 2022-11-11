
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221111013108647650"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "139c1ba7-76f3-4ded-b09b-12e82196d826"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
