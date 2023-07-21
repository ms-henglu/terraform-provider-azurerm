
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "dd0147eb-18e7-4e6c-863b-060ac259434e"
  name               = "acctestrd-230721014459551739"
  scope              = data.azurerm_subscription.primary.id
  description        = "Acceptance Test Role Definition"

  permissions {
    actions          = ["*"]
    data_actions     = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
    not_actions      = ["Microsoft.Authorization/*/read"]
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}
