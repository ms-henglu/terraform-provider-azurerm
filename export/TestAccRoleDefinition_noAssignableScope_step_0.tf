
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "81a2c588-2915-43ef-bb5c-03023c2955c2"
  name               = "acctestrd-220916011112706466"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
