
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117230517450126"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c04a3a1a-b7a4-470e-adcd-301f37640233"
  name               = "acctestrd-221117230517450126"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
