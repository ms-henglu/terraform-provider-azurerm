
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924003911437950"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cdc5636f-55cd-434c-b9ae-8e9309d1d1c0"
  name               = "acctestrd-210924003911437950"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
