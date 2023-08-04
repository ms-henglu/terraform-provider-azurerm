

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-230804030028032383"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2308040383"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2308040383"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"

  tags = {
    environment = "Prod"
  }
  depends_on = [azurerm_healthcare_workspace.test]
}
