

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-medTech-230630033247552409"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-ehn-230630033247552409"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-eh-230630033247552409"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub" "test1" {
  name                = "acctest-eh1-230630033247552409"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctestCG-230630033247552409"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventhub_consumer_group" "test1" {
  name                = "acctestCG1-230630033247552409"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test1.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "wks230630033247552409"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_healthcare_medtech_service" "test" {
  name         = "mt230630033247552409"
  workspace_id = azurerm_healthcare_workspace.test.id
  location     = azurerm_resource_group.test.location

  eventhub_namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name                = azurerm_eventhub.test.name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.test.name

  device_mapping_json = <<JSON
{
   "templateType": "CollectionContent",
            "template": [
              {
                "templateType": "JsonPathContent",
                "template": {
                  "typeName": "heartrate",
                  "typeMatchExpression": "$..[?(@heartrate)]",
                  "deviceIdExpression": "$.deviceid",
                  "timestampExpression": "$.measurementdatetime",
                  "values": [
                    {
                      "required": "true",
                      "valueExpression": "$.heartrate",
                      "valueName": "hr"
                    }
                  ]
                }
              }
            ]
}
JSON
}
