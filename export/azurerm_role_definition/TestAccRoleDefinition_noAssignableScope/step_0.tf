
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "84390a14-e176-4374-9951-63ee44d10cc4"
  name               = "acctestrd-221111013108642964"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
