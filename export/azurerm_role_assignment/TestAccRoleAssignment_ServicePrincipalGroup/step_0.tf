
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230512010230730977"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "750a6ea0-db40-4837-a3a3-2920d3234487"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
