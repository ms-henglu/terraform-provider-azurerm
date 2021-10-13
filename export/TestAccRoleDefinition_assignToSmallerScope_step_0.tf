
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071533255729"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9d9a3373-ef02-42a3-82fd-08eed4feab85"
  name               = "acctestrd-211013071533255729"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
