
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name = "TestAcc-Deployment-240119022750528244"
}

resource "azurerm_management_group_template_deployment" "test" {
  name                = "acctestMGdeploy-240119022750528244"
  management_group_id = azurerm_management_group.test.id
  location            = "West Europe"

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
