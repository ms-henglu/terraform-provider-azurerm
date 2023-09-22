
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922060523579004"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230922060523579004"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsadsalabx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_application_insights_workbook" "test" {
  name                 = "0f498fab-2989-4395-b084-fc092d83a6b1"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  display_name         = "acctest-amw-1"
  source_id            = lower(azurerm_resource_group.test.id)
  category             = "workbook1"
  description          = "description1"
  storage_container_id = azurerm_storage_container.test.resource_manager_id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "Test2021"
        },
        "name" = "text - 0"
      }
    ],
    "isLocked" = false,
    "fallbackResourceIds" = [
      "Azure Monitor"
    ]
  })
  tags = {
    env = "test"
  }

  depends_on = [
    azurerm_role_assignment.test,
  ]
}
