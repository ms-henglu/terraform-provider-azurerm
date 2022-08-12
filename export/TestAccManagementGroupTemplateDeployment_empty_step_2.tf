
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name = "TestAcc-Deployment-220812015659777076"
}

resource "azurerm_management_group_template_deployment" "test" {
  name                = "acctestMGdeploy-220812015659777076"
  management_group_id = azurerm_management_group.test.id
  location            = "West Europe"
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
