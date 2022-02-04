
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204055703964332"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "8fe5852a-9a43-4119-a16d-e5ae763e9bc5"
  name               = "acctestrd-220204055703964332"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
