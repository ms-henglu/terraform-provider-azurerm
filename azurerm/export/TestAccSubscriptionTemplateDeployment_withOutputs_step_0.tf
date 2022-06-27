
provider "azurerm" {
  features {}
}

resource "azurerm_subscription_template_deployment" "test" {
  name     = "acctestsubdeploy-220627134932692949"
  location = "West Europe"

  template_content = <<TEMPLATE
{
  "$schema": "https://pluginsdk.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [],
  "outputs": {
    "testOutput": {
      "type": "String",
      "value": "some-value"
    }
  }
}
TEMPLATE
}
