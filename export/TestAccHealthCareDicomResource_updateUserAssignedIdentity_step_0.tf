

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-220715004510612053"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2207150053"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2207150053"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "None"
  }
  depends_on = [azurerm_healthcare_workspace.test]
}
