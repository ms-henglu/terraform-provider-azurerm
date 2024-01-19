
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240119021540829000"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "30f495e9-6ef5-46fd-9c60-c4ad1516d9e0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
