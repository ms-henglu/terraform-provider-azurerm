
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028164609358567"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "50594590-93d2-40ed-bb59-8bf5b676f998"
  name               = "acctestrd-221028164609358567"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
