
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152773721"
  location = "West Europe"
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "healthdicomservicename" = {
      value = "hd231013044152773721"
    },
    "healthworkspacename" = {
      value = "hw231013044152773721"
    }
  })

  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "healthdicomservicename": {
      "type": "String",
      "defaultValue": ""
    },
    "healthworkspacename": {
      "type": "String",
      "defaultValue": ""
    }
  },
  "resources": [
    {
      "type": "Microsoft.HealthcareApis/workspaces",
      "apiVersion": "2022-06-01",
      "name": "[parameters('healthworkspacename')]",
      "location": "West Europe"
    },
    {
      "type": "Microsoft.HealthcareApis/workspaces/dicomservices",
      "apiVersion": "2022-06-01",
      "name": "[concat(parameters('healthworkspacename'), '/', parameters('healthdicomservicename'))]",
      "location": "West Europe",
      "dependsOn": [
        "[resourceId('Microsoft.HealthcareApis/workspaces', parameters('healthworkspacename'))]"
      ]
    }
  ]
}
TEMPLATE
}
