package springcloud

import (
	"fmt"
	"log"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	cosmosValidate "github.com/hashicorp/terraform-provider-azurerm/internal/services/cosmos/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/springcloud/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

const (
	springCloudAppCosmosDbAssociationKeyAPIType        = "apiType"
	springCloudAppCosmosDbAssociationKeyCollectionName = "collectionName"
	springCloudAppCosmosDbAssociationKeyDatabaseName   = "databaseName"
	springCloudAppCosmosDbAssociationKeyKeySpace       = "keySpace"

	springCloudAppCosmosDbAssociationAPITypeCassandra = "cassandra"
	springCloudAppCosmosDbAssociationAPITypeGremlin   = "gremlin"
	springCloudAppCosmosDbAssociationAPITypeMongo     = "mongo"
	springCloudAppCosmosDbAssociationAPITypeSql       = "sql"
	springCloudAppCosmosDbAssociationAPITypeTable     = "table"
)

func resourceSpringCloudAppCosmosDBAssociation() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudAppCosmosDBAssociationCreateUpdate,
		Read:   resourceSpringCloudAppCosmosDBAssociationRead,
		Update: resourceSpringCloudAppCosmosDBAssociationCreateUpdate,
		Delete: resourceSpringCloudAppCosmosDBAssociationDelete,

		Importer: pluginsdk.ImporterValidatingResourceIdThen(func(id string) error {
			_, err := appplatform.ParseBindingIDInsensitively(id)
			return err
		}, importSpringCloudAppAssociation(springCloudAppAssociationTypeCosmosDb)),

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
				ValidateFunc: validate.SpringCloudAppID,
			},

			"cosmosdb_account_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: cosmosValidate.DatabaseAccountID,
			},

			"api_type": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
				ValidateFunc: validation.StringInSlice([]string{
					springCloudAppCosmosDbAssociationAPITypeCassandra,
					springCloudAppCosmosDbAssociationAPITypeGremlin,
					springCloudAppCosmosDbAssociationAPITypeMongo,
					springCloudAppCosmosDbAssociationAPITypeSql,
					springCloudAppCosmosDbAssociationAPITypeTable,
				}, false),
			},

			"cosmosdb_access_key": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"cosmosdb_cassandra_keyspace_name": {
				Type:          pluginsdk.TypeString,
				Optional:      true,
				ValidateFunc:  cosmosValidate.CosmosEntityName,
				ConflictsWith: []string{"cosmosdb_gremlin_database_name", "cosmosdb_gremlin_graph_name", "cosmosdb_mongo_database_name", "cosmosdb_sql_database_name"},
			},

			"cosmosdb_gremlin_database_name": {
				Type:          pluginsdk.TypeString,
				Optional:      true,
				ValidateFunc:  cosmosValidate.CosmosEntityName,
				RequiredWith:  []string{"cosmosdb_gremlin_graph_name"},
				ConflictsWith: []string{"cosmosdb_cassandra_keyspace_name", "cosmosdb_mongo_database_name", "cosmosdb_sql_database_name"},
			},

			"cosmosdb_gremlin_graph_name": {
				Type:          pluginsdk.TypeString,
				Optional:      true,
				ValidateFunc:  cosmosValidate.CosmosEntityName,
				RequiredWith:  []string{"cosmosdb_gremlin_database_name"},
				ConflictsWith: []string{"cosmosdb_cassandra_keyspace_name", "cosmosdb_mongo_database_name", "cosmosdb_sql_database_name"},
			},

			"cosmosdb_mongo_database_name": {
				Type:          pluginsdk.TypeString,
				Optional:      true,
				ValidateFunc:  cosmosValidate.CosmosEntityName,
				ConflictsWith: []string{"cosmosdb_cassandra_keyspace_name", "cosmosdb_gremlin_database_name", "cosmosdb_gremlin_graph_name", "cosmosdb_sql_database_name"},
			},

			"cosmosdb_sql_database_name": {
				Type:          pluginsdk.TypeString,
				Optional:      true,
				ValidateFunc:  cosmosValidate.CosmosEntityName,
				ConflictsWith: []string{"cosmosdb_cassandra_keyspace_name", "cosmosdb_gremlin_database_name", "cosmosdb_gremlin_graph_name", "cosmosdb_mongo_database_name"},
			},
		},
	}
}

func resourceSpringCloudAppCosmosDBAssociationCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
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
			return tf.ImportAsExistsError("azurerm_spring_cloud_app_cosmosdb_association", id.ID())
		}
	}

	apiType := d.Get("api_type").(string)
	cassandraKeyspaceName := d.Get("cosmosdb_cassandra_keyspace_name")
	gremlinDatabaseName := d.Get("cosmosdb_gremlin_database_name")
	gremlinGraphName := d.Get("cosmosdb_gremlin_graph_name")
	mongoDatabaseName := d.Get("cosmosdb_mongo_database_name")
	sqlDatabaseName := d.Get("cosmosdb_sql_database_name")

	bindingParameters := map[string]interface{}{
		springCloudAppCosmosDbAssociationKeyAPIType: apiType,
	}

	switch apiType {
	case springCloudAppCosmosDbAssociationAPITypeCassandra:
		if cassandraKeyspaceName == "" {
			return fmt.Errorf("`cosmosdb_cassandra_keyspace_name` should be set if `api_type` is `%s`", apiType)
		}
		bindingParameters[springCloudAppCosmosDbAssociationKeyKeySpace] = cassandraKeyspaceName
	case springCloudAppCosmosDbAssociationAPITypeGremlin:
		if gremlinDatabaseName == "" || gremlinGraphName == "" {
			return fmt.Errorf("`cosmosdb_gremlin_database_name` and `cosmosdb_gremlin_graph_name` should be set if `api_type` is `%s`", apiType)
		}
		bindingParameters[springCloudAppCosmosDbAssociationKeyDatabaseName] = gremlinDatabaseName
		bindingParameters[springCloudAppCosmosDbAssociationKeyCollectionName] = gremlinGraphName
	case springCloudAppCosmosDbAssociationAPITypeMongo:
		if mongoDatabaseName == "" {
			return fmt.Errorf("`cosmosdb_mongo_database_name` should be set if `api_type` is `%s`", apiType)
		}
		bindingParameters[springCloudAppCosmosDbAssociationKeyDatabaseName] = mongoDatabaseName
	case springCloudAppCosmosDbAssociationAPITypeSql:
		if sqlDatabaseName == "" {
			return fmt.Errorf("`cosmosdb_sql_database_name` should be set if `api_type` is `%s`", apiType)
		}
		bindingParameters[springCloudAppCosmosDbAssociationKeyDatabaseName] = sqlDatabaseName
	case springCloudAppCosmosDbAssociationAPITypeTable:
		if cassandraKeyspaceName != "" || gremlinDatabaseName != "" || gremlinGraphName != "" || mongoDatabaseName != "" || sqlDatabaseName != "" {
			return fmt.Errorf("`cosmosdb_cassandra_keyspace_name`, `cosmosdb_gremlin_database_name`, `cosmosdb_gremlin_graph_name`, `cosmosdb_mongo_database_name`, `cosmosdb_sql_database_name` should not be set if `api_type` is `%s`", apiType)
		}
	}

	bindingResource := appplatform.BindingResource{
		Properties: &appplatform.BindingResourceProperties{
			BindingParameters: &bindingParameters,
			Key:               utils.String(d.Get("cosmosdb_access_key").(string)),
			ResourceId:        utils.String(d.Get("cosmosdb_account_id").(string)),
		},
	}

	err = client.BindingsCreateOrUpdateThenPoll(ctx, id, bindingResource)
	if err != nil {
		return fmt.Errorf("creating %s: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceSpringCloudAppCosmosDBAssociationRead(d, meta)
}

func resourceSpringCloudAppCosmosDBAssociationRead(d *pluginsdk.ResourceData, meta interface{}) error {
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
		d.Set("cosmosdb_account_id", props.ResourceId)

		apiType := ""
		cassandraKeyspaceName := ""
		mongoDatabaseName := ""
		sqlDatabaseName := ""
		gremlinDatabaseName := ""
		gremlinGraphName := ""
		if props.BindingParameters != nil {
			if v, ok := (*props.BindingParameters)[springCloudAppCosmosDbAssociationKeyAPIType]; ok {
				apiType = v.(string)
			}

			if v, ok := (*props.BindingParameters)[springCloudAppCosmosDbAssociationKeyKeySpace]; ok {
				cassandraKeyspaceName = v.(string)
			}

			if v, ok := (*props.BindingParameters)[springCloudAppCosmosDbAssociationKeyDatabaseName]; ok {
				switch apiType {
				case springCloudAppCosmosDbAssociationAPITypeMongo:
					mongoDatabaseName = v.(string)
				case springCloudAppCosmosDbAssociationAPITypeSql:
					sqlDatabaseName = v.(string)
				case springCloudAppCosmosDbAssociationAPITypeGremlin:
					gremlinDatabaseName = v.(string)
				}
			}
			if v, ok := (*props.BindingParameters)[springCloudAppCosmosDbAssociationKeyCollectionName]; ok {
				gremlinGraphName = v.(string)
			}

		}

		d.Set("api_type", apiType)
		d.Set("cosmosdb_cassandra_keyspace_name", cassandraKeyspaceName)
		d.Set("cosmosdb_gremlin_database_name", gremlinDatabaseName)
		d.Set("cosmosdb_mongo_database_name", mongoDatabaseName)
		d.Set("cosmosdb_sql_database_name", sqlDatabaseName)
		d.Set("cosmosdb_gremlin_graph_name", gremlinGraphName)
	}
	return nil
}

func resourceSpringCloudAppCosmosDBAssociationDelete(d *pluginsdk.ResourceData, meta interface{}) error {
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
