
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060618360502"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "fd99c842-3d71-4a26-a3ff-fb5f9a11f490"
  name               = "acctestrd-230922060618360502"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
