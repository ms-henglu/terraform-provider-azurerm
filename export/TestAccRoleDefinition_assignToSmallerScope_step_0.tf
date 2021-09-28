
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055146806167"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d8229e4c-01e2-4e55-89fc-3dbda21e73fa"
  name               = "acctestrd-210928055146806167"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
