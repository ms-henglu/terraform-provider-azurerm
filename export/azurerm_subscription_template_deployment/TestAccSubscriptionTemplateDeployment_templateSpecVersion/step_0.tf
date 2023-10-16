
provider "azurerm" {
  features {}
}

data "azurerm_template_spec_version" "test" {
  name                = "acctest-standing-data-for-sub"
  resource_group_name = "standing-data-for-acctest"
  version             = "v1.0.0"
}

resource "azurerm_subscription_template_deployment" "test" {
  name     = "acctestsubdeploy-231016034629731799"
  location = "West Europe"

  template_spec_version_id = data.azurerm_template_spec_version.test.id

  parameters_content = <<PARAM
{
  "rgName": {
   "value": "acctest-rg-tspec-231016034629731799"
  },
  "rgLocation": {
   "value": "West Europe"
  },
  "tags": {
   "value": {}
  }
}
PARAM
}
