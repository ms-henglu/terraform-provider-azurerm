
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011145763516"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "71a5d678-d481-4ba6-b4b6-8d7354728ff5"
  name               = "acctestrd-230721011145763516"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
