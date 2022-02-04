
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-220204060543045385"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-220204060543045385"

  policy_rule = <<POLICY_RULE
	{
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE


  parameters = <<PARAMETERS
	{
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS

}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060543045385"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220204060543045385"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-220204060543045385"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "Acceptance Test Run 220204060543045385"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctestrgtd-220204060543045385"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Incremental"

  template_content = <<TEMPLATE
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "description": {
            "type": "String"
        },
        "displayName": {
          "type": "String"
        },
        "exemptionCategory": {
          "type": "String",
          "allowedValues": [
            "Waiver",
            "Mitigated"
          ]
        },
        "expiresOn": {
          "type": "String"
        },
        "metadata": {
          "type": "Object"
        },
        "name": {
          "type": "String"
        },
        "policyAssignmentId": {
          "type": "String"
        },
        "policyDefinitionReferenceIds": {
          "type": "Array"
        },
        "scope": {
          "type": "String"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Authorization/policyExemptions",
            "name": "[parameters('name')]",
            "apiVersion": "2020-07-01-preview",
            "scope": "[parameters('scope')]",
            "properties": {
                "description": "[parameters('description')]",
                "displayName": "[parameters('displayName')]",
                "exemptionCategory": "[parameters('exemptionCategory')]",
                "expiresOn": "[parameters('expiresOn')]",
                "metadata": "[parameters('metadata')]",
                "policyAssignmentId": "[parameters('policyAssignmentId')]",
                "policyDefinitionReferenceIds": "[parameters('policyDefinitionReferenceIds')]"
            }
        }
    ]
}
TEMPLATE

  parameters_content = <<PARAM
{
  "description": {
   "value": "description-220204060543045385"
  },
  "displayName": {
    "value": "name--220204060543045385"
  },
  "exemptionCategory": {
    "value": "Waiver"
  },
  "expiresOn": {
    "value": ""
  },
  "metadata": {
    "value": {}
  },
  "name": {
    "value": "name--220204060543045385"
  },
  "policyAssignmentId": {
    "value": "${azurerm_policy_assignment.test.id}"
  },
  "policyDefinitionReferenceIds": {
    "value": []
  },
  "scope": {
    "value": "${azurerm_log_analytics_workspace.test.id}"
  }
}
PARAM
}

