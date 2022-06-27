
provider "azurerm" {
  features {}
}

resource "azurerm_subscription_template_deployment" "test" {
  name     = "acctestsubdeploy-220627134932698562"
  location = "West Europe"

  template_content = <<TEMPLATE
{
  "$schema": "https://pluginsdk.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2018-05-01",
      "location": "West Europe",
      "name": "acctestrg-220627134932698562",
      "properties": {},
      "tags": {
        "Hello": "second"
      }
    }
  ]
}
TEMPLATE
}
