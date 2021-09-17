

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-video-analyzer-210917032318534435"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-210917032318534435"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_storage_account.first.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_storage_account.first.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1rswk6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_video_analyzer" "test" {
  name                = "acctestvarswk6"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id                        = azurerm_storage_account.first.id
    user_assigned_identity_id = azurerm_user_assigned_identity.test.id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  depends_on = [
    azurerm_user_assigned_identity.test,
    azurerm_role_assignment.contributor,
    azurerm_role_assignment.reader,
  ]
}



resource "azurerm_video_analyzer_edge_module" "test" {
  name                = "acctestVAEMrswk6"
  resource_group_name = azurerm_resource_group.test.name
  video_analyzer_name = azurerm_video_analyzer.test.name
}
