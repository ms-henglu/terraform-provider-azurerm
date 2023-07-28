
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025052157431"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "6890eadb-e0c9-450d-a511-be98346fc28e"
  name               = "acctestrd-230728025052157431"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
