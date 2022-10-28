


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-221028172223569923"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2210281723"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2210281723"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"
  depends_on   = [azurerm_healthcare_workspace.test]
}

resource "azurerm_healthcare_dicom_service" "import" {
  name         = azurerm_healthcare_dicom_service.test.name
  workspace_id = azurerm_healthcare_dicom_service.test.workspace_id
  location     = azurerm_healthcare_dicom_service.test.location
}
