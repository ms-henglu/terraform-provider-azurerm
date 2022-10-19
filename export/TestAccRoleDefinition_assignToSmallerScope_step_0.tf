
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019053857958863"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "bc534968-9d5a-4aa9-a28f-81c79342712d"
  name               = "acctestrd-221019053857958863"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
