


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240119024449259865"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240119024449259865"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAqCWpofqC48uRnCz8T60/pL4hSi8ZFsyP9YvA85b2E1HrT0g91X7UiiwRiGq51jbYm05ug7UjdM91OeOit9QxzD4+g6UPx/+utOgO5HDe0SmnDqw2TiFTXVPjE/VDg7dPLAnOuFsr+vfQKeXSbxHgr4XmCWZePQVbWgyaHZn/ACm+QFQnU8xq0/fom7mVU9mqROjrvBfjXsPiO+xVug6G8JlxqycK0Bl2TthNCjCpk5QaiJPictbygrYBcvyXyLjubCd9RQ25/In/oDGJmgnFHdJWYJlcZtGQd9DqxHsiSHWIaiRHOeFceulcnmB2WCP6MiVlwthzvmWu9Rb6v8PzBzWVBf3KuA37uOf10ua0O7ZYyxhOI7TpujxuuON/cmy0Qy0mGcNKb0EDPg/yU935ArU/68dUqPuqlVgMs6w28T3hnMr4MkgGGyDTexj1MFOjn6UZXcLr3YkFCeqYT1CfDsGcATXjvsWDyWO2Hmdexk+Z3C0J97TpcytSHabhQ7o62egHGcyGrA77wzhcYB/1HHYVT3A32AZNlZYcPmeEH3efI473xQynziDfDj4vK7/Vmpy5i5sZzTjvYNk2F0zcIoCgA6fvoRKEZ8UQgnvz7o7YJhD+nN3NjyKrxeiMEH6W0V38mHUxELYCSFHQc9iwj+Aj+v8GszL0E6lpEollhMcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
