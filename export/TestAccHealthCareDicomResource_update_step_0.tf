

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-220826002809384189"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2208260089"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2208260089"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"
  depends_on   = [azurerm_healthcare_workspace.test]
}
