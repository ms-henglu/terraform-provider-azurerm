
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003334299306"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4d0d4727-5398-4584-ab7a-e76ece2d2ece"
  name               = "acctestrd-230707003334299306"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
