
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041756199820"
  location = "West Europe"
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Complete"

  template_content = <<TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {},
      "variables": {},
      "resources": [
        {
          "type": "Microsoft.Insights/actionGroups",
          "apiVersion": "2019-06-01",
          "name": "acctestTemplateDeployAG1-231020041756199820",
          "location": "Global",
          "dependsOn": [],
          "tags": {},
          "properties": {
            "groupShortName": "rick-c137",
            "enabled": true,
            "emailReceivers": [
              {
                "name": "Rick Sanchez",
                "emailAddress": "rick@example.com"
              }
            ],
            "smsReceivers": [],
            "webhookReceivers": []
          }
        },
        {
          "type": "microsoft.insights/actionGroups",
          "apiVersion": "2019-06-01",
          "name": "acctestTemplateDeployAG2-231020041756199820",
          "location": "Global",
          "dependsOn": [],
          "tags": {},
          "properties": {
            "groupShortName": "rick-c138",
            "enabled": true,
            "emailReceivers": [
              {
                "name": "Rick Sanchez",
                "emailAddress": "rick@example.com"
              }
            ],
            "smsReceivers": [],
            "webhookReceivers": []
          }
        }
      ]
    }
TEMPLATE
}
  