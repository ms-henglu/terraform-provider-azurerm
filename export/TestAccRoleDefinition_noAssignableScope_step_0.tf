
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7ddd5aa8-d9e2-4bbf-8ace-b0fe46c993d3"
  name               = "acctestrd-220819164917643878"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
