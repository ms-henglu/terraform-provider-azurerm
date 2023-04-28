

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-medTech-230428045827236361"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-ehn-230428045827236361"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-eh-230428045827236361"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub" "test1" {
  name                = "acctest-eh1-230428045827236361"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctestCG-230428045827236361"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventhub_consumer_group" "test1" {
  name                = "acctestCG1-230428045827236361"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test1.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wks230428045827236361"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_healthcare_medtech_service" "test" {
  name         = "mt230428045827236361"
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
