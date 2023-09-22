


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-healthcareapi-230922054224197850"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acc230922054224197850"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_healthcare_fhir_service" "test" {
  name                = "fhir230922054224197850"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_healthcare_workspace.test.id
  kind                = "fhir-R4"

  authentication {
    authority = "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47"
    audience  = "https://acctestfhir.fhir.azurehealthcareapis.com"
  }
}

resource "azurerm_healthcare_fhir_service" "import" {
  name                = azurerm_healthcare_fhir_service.test.name
  location            = azurerm_healthcare_fhir_service.test.location
  resource_group_name = azurerm_healthcare_fhir_service.test.resource_group_name
  workspace_id        = azurerm_healthcare_fhir_service.test.workspace_id
  kind                = azurerm_healthcare_fhir_service.test.kind

  authentication {
    authority = azurerm_healthcare_fhir_service.test.authentication[0].authority
    audience  = azurerm_healthcare_fhir_service.test.authentication[0].audience
  }
}
