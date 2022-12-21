
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221221203945895205"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8c314d40-c326-49d6-be66-04c1557fb460"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
