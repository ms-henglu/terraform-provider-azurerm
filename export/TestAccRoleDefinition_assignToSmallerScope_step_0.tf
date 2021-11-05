
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105035542371663"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "459c28d7-ca51-4ae4-8c78-7ca5767e9767"
  name               = "acctestrd-211105035542371663"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
