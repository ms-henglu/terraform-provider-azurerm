
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120051526475704"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d02dfb2a-c91b-49a7-bffd-fad98e9e0933"
  name               = "acctestrd-230120051526475704"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
