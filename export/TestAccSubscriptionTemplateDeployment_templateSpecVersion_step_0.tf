
provider "azurerm" {
  features {}
}

data "azurerm_template_spec_version" "test" {
  name                = "acctest-standing-data-for-sub"
  resource_group_name = "standing-data-for-acctest"
  version             = "v1.0.0"
}

resource "azurerm_subscription_template_deployment" "test" {
  name     = "acctestsubdeploy-220630211256610593"
  location = "West Europe"

  template_spec_version_id = data.azurerm_template_spec_version.test.id

  parameters_content = <<PARAM
{
  "rgName": {
   "value": "acctest-rg-tspec-220630211256610593"
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
