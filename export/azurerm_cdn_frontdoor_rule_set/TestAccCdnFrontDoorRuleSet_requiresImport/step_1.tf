

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-231016033515757385"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-fdprofile-231016033515757385"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "acctestfdruleset23101685"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_rule_set" "import" {
  name                     = azurerm_cdn_frontdoor_rule_set.test.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
