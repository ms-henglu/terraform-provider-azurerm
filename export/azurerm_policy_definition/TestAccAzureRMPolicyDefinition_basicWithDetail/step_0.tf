
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-240119025606769898"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-240119025606769898"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "field": "type",
    "equals": "Microsoft.ServiceBus/namespaces"
  },
  "then": {
    "effect": "DeployIfNotExists",
    "details": {
      "type": "Microsoft.Insights/diagnosticSettings",
      "name": "acctest",
      "roleDefinitionIds": [
        "/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ],
      "deployment": {
        "properties": {
          "mode": "incremental",
          "template": {
            "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {}
          }
        }
      }
    }
  }
}
POLICY_RULE
}
