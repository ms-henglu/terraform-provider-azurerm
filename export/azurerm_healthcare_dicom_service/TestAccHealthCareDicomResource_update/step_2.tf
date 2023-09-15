

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dicom-230915023514586618"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wk2309150218"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_healthcare_dicom_service" "test" {
  name         = "dicom2309150218"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = "West Europe"

  tags = {
    environment = "Prod"
  }
  depends_on = [azurerm_healthcare_workspace.test]
}
