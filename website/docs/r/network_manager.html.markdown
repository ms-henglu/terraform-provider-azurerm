---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_manager"
description: |-
  Manages a network Manager.
---

# azurerm_network_manager

Manages a network Manager.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name                = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this network Manager. Changing this forces a new network Manager to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the network Manager should exist. Changing this forces a new network Manager to be created.

* `location` - (Required) The Azure Region where the network Manager should exist. Changing this forces a new network Manager to be created.

* `network_manager_scope_accesses` - (Required) Scope Access. Possible values are TODO
  
* `network_manager_scopes` - (Required) A `network_manager_scopes` block as defined below.
---

* `description` - (Optional) A description of the network manager. 

* `display_name` - (Optional) A friendly name for the network manager. 

* `tags` - (Optional) A mapping of tags which should be assigned to the network Manager.

---

An `network_manager_scopes` block exports the following:

* `management_groups` - (Optional) List of management groups. Changing this forces a new network Manager to be created.

* `subscriptions` - (Optional) List of subscriptions. Changing this forces a new network Manager to be created.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the network Manager.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the network Manager.
* `read` - (Defaults to 5 minutes) Used when retrieving the network Manager.
* `update` - (Defaults to 30 minutes) Used when updating the network Manager.
* `delete` - (Defaults to 30 minutes) Used when deleting the network Manager.

## Import

network Managers can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_manager.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/networkManagers/networkManager1
```
