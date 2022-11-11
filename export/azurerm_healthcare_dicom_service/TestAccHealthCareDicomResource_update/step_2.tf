

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-221111013627577531"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2211110131"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2211110131"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"

  tags = {
    environment = "Prod"
  }
  depends_on = [azurerm_healthcare_workspace.test]
}
