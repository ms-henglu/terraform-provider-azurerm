

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-221028172223568471"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2210281771"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2210281771"
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
