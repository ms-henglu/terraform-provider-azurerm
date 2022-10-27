package springcloud

import (
	"context"
	"fmt"

	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
)

const (
	springCloudAppAssociationTypeCosmosDb = "Microsoft.DocumentDB"
	springCloudAppAssociationTypeMysql    = "Microsoft.DBforMySQL"
	springCloudAppAssociationTypeRedis    = "Microsoft.Cache"
)

func importSpringCloudAppAssociation(resourceType string) pluginsdk.ImporterFunc {
	return func(ctx context.Context, d *pluginsdk.ResourceData, meta interface{}) (data []*pluginsdk.ResourceData, err error) {
		id, err := appplatform.ParseBindingIDInsensitively(d.Id())
		if err != nil {
			return []*pluginsdk.ResourceData{}, err
		}

		client := meta.(*clients.Client).AppPlatform.AppPlatformClient
		resp, err := client.BindingsGet(ctx, *id)
		if err != nil {
			return []*pluginsdk.ResourceData{}, fmt.Errorf("retrieving %s: %+v", id, err)
		}

		if resp.Model.Properties == nil || resp.Model.Properties.ResourceType == nil {
			return []*pluginsdk.ResourceData{}, fmt.Errorf("retrieving %s: `properties` or `properties.resourceType` was nil", id)
		}

		if *resp.Model.Properties.ResourceType != resourceType {
			return []*pluginsdk.ResourceData{}, fmt.Errorf(`spring Cloud App Association "type" mismatch, expected "%s", got "%s"`, resourceType, *resp.Model.Properties.ResourceType)
		}

		return []*pluginsdk.ResourceData{d}, nil
	}
}
