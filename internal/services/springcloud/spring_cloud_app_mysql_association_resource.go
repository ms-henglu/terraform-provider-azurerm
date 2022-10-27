package springcloud

import (
	"fmt"
	"log"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	mysqlValidate "github.com/hashicorp/terraform-provider-azurerm/internal/services/mysql/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

const (
	springCloudAppMysqlAssociationKeyDatabase = "databaseName"
	springCloudAppMysqlAssociationKeyUsername = "username"
)

func resourceSpringCloudAppMysqlAssociation() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudAppMysqlAssociationCreateUpdate,
		Read:   resourceSpringCloudAppMysqlAssociationRead,
		Update: resourceSpringCloudAppMysqlAssociationCreateUpdate,
		Delete: resourceSpringCloudAppMysqlAssociationDelete,

		Importer: pluginsdk.ImporterValidatingResourceIdThen(func(id string) error {
			_, err := appplatform.ParseBindingIDInsensitively(id)
			return err
		}, importSpringCloudAppAssociation(springCloudAppAssociationTypeMysql)),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.SpringCloudAppAssociationName,
			},

			"spring_cloud_app_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: appplatform.ValidateAppID,
			},

			"mysql_server_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: mysqlValidate.ServerID,
			},

			"database_name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"username": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"password": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				Sensitive:    true,
				ValidateFunc: validation.StringIsNotEmpty,
			},
		},
	}
}

func resourceSpringCloudAppMysqlAssociationCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	appId, err := appplatform.ParseAppIDInsensitively(d.Get("spring_cloud_app_id").(string))
	if err != nil {
		return err
	}

	id := appplatform.NewBindingID(appId.SubscriptionId, appId.ResourceGroupName, appId.ServiceName, appId.AppName, d.Get("name").(string))
	if d.IsNewResource() {
		existing, err := client.BindingsGet(ctx, id)
		if err != nil {
			if !response.WasNotFound(existing.HttpResponse) {
				return fmt.Errorf("checking for presence of existing %s: %+v", id, err)
			}
		}
		if !response.WasNotFound(existing.HttpResponse) {
			return tf.ImportAsExistsError("azurerm_spring_cloud_app_mysql_association", id.ID())
		}
	}

	bindingResource := appplatform.BindingResource{
		Properties: &appplatform.BindingResourceProperties{
			BindingParameters: &map[string]interface{}{
				springCloudAppMysqlAssociationKeyDatabase: d.Get("database_name").(string),
				springCloudAppMysqlAssociationKeyUsername: d.Get("username").(string),
			},
			Key:        utils.String(d.Get("password").(string)),
			ResourceId: utils.String(d.Get("mysql_server_id").(string)),
		},
	}

	err = client.BindingsCreateOrUpdateThenPoll(ctx, id, bindingResource)
	if err != nil {
		return fmt.Errorf("creating %s: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceSpringCloudAppMysqlAssociationRead(d, meta)
}

func resourceSpringCloudAppMysqlAssociationRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseBindingIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.BindingsGet(ctx, *id)
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			log.Printf("[INFO] Spring Cloud App Association %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("reading %s: %+v", id, err)
	}

	d.Set("name", id.BindingName)
	d.Set("spring_cloud_app_id", appplatform.NewAppID(id.SubscriptionId, id.ResourceGroupName, id.ServiceName, id.AppName).ID())
	if props := resp.Model.Properties; props != nil {
		d.Set("mysql_server_id", props.ResourceId)

		databaseName := ""
		username := ""
		if props.BindingParameters != nil {
			if v, ok := (*props.BindingParameters)[springCloudAppMysqlAssociationKeyDatabase]; ok {
				databaseName = v.(string)
			}
			if v, ok := (*props.BindingParameters)[springCloudAppMysqlAssociationKeyUsername]; ok {
				username = v.(string)
			}
		}
		d.Set("database_name", databaseName)
		d.Set("username", username)
	}
	return nil
}

func resourceSpringCloudAppMysqlAssociationDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseBindingIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	err = client.BindingsDeleteThenPoll(ctx, *id)
	if err != nil {
		return fmt.Errorf("deleting %s: %+v", id, err)
	}

	return nil
}
