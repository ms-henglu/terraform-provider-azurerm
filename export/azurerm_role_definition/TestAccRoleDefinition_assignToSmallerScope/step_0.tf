
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023517084936"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "0bfff42d-c23d-4f8f-84c7-743263170811"
  name               = "acctestrd-230818023517084936"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
