
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 230414021911089489"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-mg-ey9u1"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-mg-ey9u1"
  description         = "Description for ey9u1"
  management_group_id = azurerm_management_group.test.id
  metadata            = <<METADATA
  {
    "category": "Testing"
  }
METADATA

  parameters = <<PARAMETERS
  {
    "effect": {
      "type": "String",
      "metadata": {
        "displayName": "Effect",
        "description": "Enable or disable the execution of the policy"
      },
      "allowedValues": [
        "Deny",
        "Audit",
        "Disabled"
      ],
      "defaultValue": "Deny"
    },
    "sourceIp": {
      "type": "Array",
      "metadata": {
        "displayName": "Source IP ranges",
        "description": "The inbound IP range to deny. Default to *, ANY, Internet"
      },
      "defaultValue": [
        "*",
        "Any",
        "Internet",
        "0.0.0.0"
      ]
    }
  }
PARAMETERS

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Network/networkSecurityGroups/securityRules"
        },
        {
          "allOf": [
            {
              "field": "Microsoft.Network/networkSecurityGroups/securityRules/access",
              "equals": "Allow"
            },
            {
              "field": "Microsoft.Network/networkSecurityGroups/securityRules/direction",
              "equals": "Inbound"
            },
            {
              "anyOf": [
                {
                  "field": "Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange",
                  "equals": "*"
                },
                {
                  "not": {
                    "field": "Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]",
                    "notEquals": "*"
                  }
                },
                {
                  "field": "Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix",
                  "in": "[parameters('sourceIP')]"
                },
                {
                  "not": {
                    "field": "Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefixes[*]",
                    "notIn": "[parameters('sourceIP')]"
                  }
                }
              ]
            }
          ]
        }
      ]
    },
    "then": {
      "effect": "[parameters('effect')]"
    }
  }
POLICY_RULE
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-ey9u1"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
