



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-medTech-230915023514587667"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-ehn-230915023514587667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-eh-230915023514587667"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub" "test1" {
  name                = "acctest-eh1-230915023514587667"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctestCG-230915023514587667"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventhub_consumer_group" "test1" {
  name                = "acctestCG1-230915023514587667"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test1.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wks230915023514587667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_healthcare_medtech_service" "test" {
  name         = "mt230915023514587667"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = azurerm_resource_group.test.location

  eventhub_namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name                = azurerm_eventhub.test.name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.test.name

  device_mapping_json = <<JSON
{
"templateType": "CollectionContent",
"template": []
}
JSON
}

resource "azurerm_healthcare_fhir_service" "test" {
  name                = "fhir230915023514587667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_healthcare_workspace.test.id
  kind                = "fhir-R4"

  authentication {
    authority = "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47"
    audience  = "https://acctestfhir.fhir.azurehealthcareapis.com"
  }
}

resource "azurerm_healthcare_fhir_service" "test1" {
  name                = "fhir1230915023514587667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_healthcare_workspace.test.id
  kind                = "fhir-R4"

  authentication {
    authority = "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47"
    audience  = "https://acctestfhir.fhir.azurehealthcareapis.com"
  }
}

resource "azurerm_healthcare_medtech_service_fhir_destination" "test" {
  name                                 = "des230915023514587667"
  location                             = azurerm_resource_group.test.location
  medtech_service_id                   = azurerm_healthcare_medtech_service.test.id
  destination_fhir_service_id          = azurerm_healthcare_fhir_service.test1.id
  destination_identity_resolution_type = "Create"

  destination_fhir_mapping_json = <<JSON
{
"templateType": "CollectionFhirTemplate",
"template": []
}
JSON
}