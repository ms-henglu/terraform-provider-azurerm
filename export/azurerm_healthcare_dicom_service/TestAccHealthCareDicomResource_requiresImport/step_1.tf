


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-230120054653688148"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2301200548"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2301200548"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"
  depends_on   = [azurerm_healthcare_workspace.test]
}

resource "azurerm_healthcare_dicom_service" "import" {
  name         = azurerm_healthcare_dicom_service.test.name
  workspace_id = azurerm_healthcare_dicom_service.test.workspace_id
  location     = azurerm_healthcare_dicom_service.test.location
}
