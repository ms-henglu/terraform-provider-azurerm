
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019060312735417"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e5bbf347-9fc8-42f6-a610-3958019939e5"
  name               = "acctestrd-221019060312735417"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
