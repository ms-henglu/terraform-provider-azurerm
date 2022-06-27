
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131602329404"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "0073679e-cda5-478d-a14c-ef39a3761a0a"
  name               = "acctestrd-220627131602329404"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
