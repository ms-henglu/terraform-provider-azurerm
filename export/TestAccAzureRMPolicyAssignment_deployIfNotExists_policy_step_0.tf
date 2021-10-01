
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-211001224357731604"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-211001224357731604"

  policy_rule = <<POLICY_RULE
{
	"if": {
		"field": "type",
		"equals": "Microsoft.Sql/servers/databases"
	},
	"then": {
		"effect": "DeployIfNotExists",
		"details": {
			"type": "Microsoft.Sql/servers/databases/transparentDataEncryption",
			"name": "current",
			"roleDefinitionIds": [
				"/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
			],
			"existenceCondition": {
				"field": "Microsoft.Sql/transparentDataEncryption.status",
				"equals": "Enabled"
			},
			"deployment": {
				"properties": {
					"mode": "incremental",
					"template": {
						"$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
						"contentVersion": "1.0.0.0",
						"parameters": {
							"fullDbName": {
								"type": "string"
							}
						},
						"resources": [{
							"name": "[concat(parameters('fullDbName'), '/current')]",
							"type": "Microsoft.Sql/servers/databases/transparentDataEncryption",
							"apiVersion": "2014-04-01",
							"properties": {
								"status": "Enabled"
							}
						}]
					},
					"parameters": {
						"fullDbName": {
							"value": "[field('fullName')]"
						}
					}
				}
			}
		}
	}
}
POLICY_RULE

}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224357731604"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-211001224357731604"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id

  identity {
    type = "SystemAssigned"
  }

  location = "West Europe"
}
