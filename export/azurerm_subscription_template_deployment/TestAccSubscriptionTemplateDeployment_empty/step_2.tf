
provider "azurerm" {
  features {}
}

resource "azurerm_subscription_template_deployment" "test" {
  name     = "acctestsubdeploy-231016034629737055"
  location = "West Europe"
  tags = {
    Hello = "World"
  }

  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": []
}
TEMPLATE
}
