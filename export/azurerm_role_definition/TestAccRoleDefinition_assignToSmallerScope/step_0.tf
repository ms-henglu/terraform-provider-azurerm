
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407022924639146"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "3e712a7e-cafa-4964-b519-1daa0991600e"
  name               = "acctestrd-230407022924639146"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
