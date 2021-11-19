
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-211119050518082515"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "acctestpol-211119050518082515"

  policy_rule = <<POLICY_RULE
	{
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          }
        ]
      },
      "then": {
        "effect": "modify",
        "details": {
          "roleDefinitionIds": [
            "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations": [
            {
              "operation": "addOrReplace",
              "field": "tags['managedByTenant']",
              "value": "Lighthouse"
            }
          ]
        }
      }
    }
POLICY_RULE
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-211119050518082515"
  location             = "West Europe"
  scope                = data.azurerm_subscription.primary.id
  policy_definition_id = azurerm_policy_definition.test.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "test" {
  scope                                  = data.azurerm_subscription.primary.id
  role_definition_id                     = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  delegated_managed_identity_resource_id = azurerm_policy_assignment.test.id
  principal_id                           = azurerm_policy_assignment.test.identity.0.principal_id
}
