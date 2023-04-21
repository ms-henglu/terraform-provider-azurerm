

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-230421022238486117"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2304210217"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-230421022238486117"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2304210217"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  tags = {
    environment = "None"
  }
  depends_on = [azurerm_healthcare_workspace.test, azurerm_user_assigned_identity.test]
}
