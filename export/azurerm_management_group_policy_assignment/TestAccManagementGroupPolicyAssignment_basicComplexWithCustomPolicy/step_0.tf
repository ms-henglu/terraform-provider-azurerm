
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 240105064405522491"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-mg-2cb7v"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-mg-2cb7v"
  description         = "Description for 2cb7v"
  management_group_id = azurerm_management_group.test.id
  metadata            = <<METADATA
  {
    "category": "Acceptance"
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
  name                 = "acctestpol-mg-2cb7v"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
