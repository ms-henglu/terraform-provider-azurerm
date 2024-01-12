


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240112223923457940"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240112223923457940"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEA0nRWRBM8qL4r2H2/DPL3TbUSoeipk7yU7leM/Emf9732MAyJ+ne88H3pQpx7PNCqINMCNUTu4B6HULaUQkQWwwOqtDWkKoJX07CoC0HmGxZCUw7uTL8azYT8rvysleHWb20lLHMMwdhtOCY50jHvrlcp7elUGd/bJWuzO1aSJD3UBY5CQcPZcEqFBB1jeHdYMLSF0GRP9DezT3vELo00KU1Ns0oa855z181KZ4WXOaGW7qousVnZndWBHZ9BzNX2l+hpHFg2ax5NTYSe9xoy+2kGBuLhXwBgJRLR+PESEBHPmjI4yn4oxlPcBSy9WHIFUnO3IR08yAfvmJWBOQA726Ynv1fmCVWGDlpIdy1YB2EZssB4/FzRHql1m35U/FzurfYHI8Dgf42gj/dMv59tlk9nT/BNsPfeL6U+C+AqMbYmizODvvlhtA5U3KFX7h0ucB23r8qV9wtku5Dqj7NX4T10QUwn0g8qbXE3O3GjziYCpPMudljaq+260oxziap6pXLITZoebpQxeF9s+DAqchibrqltt3tiwBbuEwxpNSkXUm75h+83/NUhVRFN353joe5VNaUyfbsSxheeZtEdgrQop5dLPX+IHaRvxfN5C/aU5AZmJHdaApEJ3I/E3csmVxl365w7Ha6xhyd8N1Gznk+z/XoMUe3H2f+HnGtkbyUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
