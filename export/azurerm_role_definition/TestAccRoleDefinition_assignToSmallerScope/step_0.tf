
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171734169330"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5ec1e26b-898b-4b9e-8440-e9d29d71d36f"
  name               = "acctestrd-221028171734169330"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
