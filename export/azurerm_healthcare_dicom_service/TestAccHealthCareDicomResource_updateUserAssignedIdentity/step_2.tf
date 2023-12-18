

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-231218071855151991"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2312180791"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-231218071855151991"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2312180791"
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
