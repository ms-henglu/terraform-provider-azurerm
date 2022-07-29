
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729032342295553"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "689983c9-6ee9-434e-ad0e-6f2b43862874"
  name               = "acctestrd-220729032342295553"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
