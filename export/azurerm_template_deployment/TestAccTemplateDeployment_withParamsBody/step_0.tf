
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072455229075"
  location = "West Europe"
}

output "test" {
  value = azurerm_template_deployment.test.outputs["testOutput"]
}

resource "azurerm_storage_container" "using-outputs" {
  name                  = "vhds"
  storage_account_name  = azurerm_template_deployment.test.outputs["accountName"]
  container_access_type = "private"
}


resource "azurerm_key_vault" "test" {
  location            = "West Europe"
  name                = "vault231218072455229075"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku_name            = "standard"

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_template_deployment = true

  access_policy {
    key_permissions = []
    object_id       = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Delete",
      "Get",
      "List",
      "Set",
      "Purge",
    ]

    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  }
}

resource "azurerm_key_vault_secret" "test-secret" {
  name         = "acctestsecret-231218072455229075"
  value        = "terraform-test-231218072455229075"
  key_vault_id = azurerm_key_vault.test.id
}

locals {
  templated-file = <<TPL
{
"dnsLabelPrefix": {
    "reference": {
      "keyvault": {
        "id": "${azurerm_key_vault.test.id}"
      },
      "secretName": "${azurerm_key_vault_secret.test-secret.name}"
    }
  },
"storageAccountType": {
   "value": "Standard_GRS"
  }
}
TPL
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-231218072455229075"
  resource_group_name = azurerm_resource_group.test.name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountType": {
      "type": "string",
      "defaultValue": "Standard_LRS",
      "allowedValues": [
        "Standard_LRS",
        "Standard_GRS",
        "Standard_ZRS"
      ],
      "metadata": {
        "description": "Storage Account type"
      }
    },
    "dnsLabelPrefix": {
      "type": "string",
      "metadata": {
        "description": "DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error."
      }
    }
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'storage')]",
    "publicIPAddressName": "[concat('myPublicIp', uniquestring(resourceGroup().id))]",
    "publicIPAddressType": "Dynamic",
    "apiVersion": "2015-06-15"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "[variables('apiVersion')]",
      "location": "[variables('location')]",
      "properties": {
        "accountType": "[parameters('storageAccountType')]"
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('apiVersion')]",
      "name": "[variables('publicIPAddressName')]",
      "location": "[variables('location')]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    }
  ],
  "outputs": {
    "testOutput": {
      "type": "string",
      "value": "Output Value"
    },
    "accountName": {
      "type": "string",
      "value": "[variables('storageAccountName')]"
    }
  }
}
DEPLOY

  parameters_body = "${local.templated-file}"
  deployment_mode = "Incremental"
  depends_on      = ["azurerm_key_vault_secret.test-secret"]
}
