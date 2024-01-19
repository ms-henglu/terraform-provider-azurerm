

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-240119025124505206"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2401190206"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2401190206"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"
  depends_on   = [azurerm_healthcare_workspace.test]
}
