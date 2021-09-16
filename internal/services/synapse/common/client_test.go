package common_test

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/hashicorp/go-azure-helpers/authentication"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"testing"
)

func getClient() (interface{}, error) {
	builder := &authentication.Builder{
		SubscriptionID: "67a9759d-d099-4aa8-8675-e6cfd669c3f4",
		ClientID:       "e03ef952-1a30-4665-a918-ad32cdba50e1",
		ClientSecret:   "Y--FC7QHYfE~~1SQXdiVm9dOq7bZC9u82A",
		TenantID:       "72f988bf-86f1-41af-91ab-2d7cd011db47",
		TenantOnly:     false,

		AuxiliaryTenantIDs: nil,
		Environment:        "public",
		MetadataHost:       "",
		MsiEndpoint:        "",
		ClientCertPassword: "",
		ClientCertPath:     "",

		//FeatureToggles
		SupportsClientCertAuth:         true,
		SupportsClientSecretAuth:       true,
		SupportsManagedServiceIdentity: false,
		SupportsAzureCliToken:          true,
		SupportsAuxiliaryTenants:       false,

		//DocLinks
		ClientSecretDocsLink: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret",
	}

	config, err := builder.Build()
	if err != nil {
		return nil, fmt.Errorf("ErrorbuildingAzureRMClient:%s", err)
	}

	clientBuilder := clients.ClientBuilder{
		AuthConfig:               config,
		SkipProviderRegistration: false,
		TerraformVersion:         "0.11+compatible",
		//PartnerId:"",
		DisableCorrelationRequestID: false,
		DisableTerraformPartnerID:   false,
		//Features:expandFeatures(d.Get("features").([]interface{})),
		StorageUseAzureAD: false,

		//thisfieldisintentionallynotexposedintheproviderblock,sinceit'sonlyusedfor
		//platformleveltracing
		CustomCorrelationRequestID: "",
	}

	client, err := clients.Build(context.Background(), clientBuilder)
	if err != nil {
		return nil, err
	}
	return client, nil
}

func TestClient2(t *testing.T) {
	client, err := getClient()
	if err != nil {
		fmt.Errorf("%v", err)
	}
	commonClient := client.(*clients.Client).Synapse.CommonClient
	url := "/subscriptions/67a9759d-d099-4aa8-8675-e6cfd669c3f4/resourceGroups/acctestRG-synapse-henglu910/providers/Microsoft.Synapse/workspaces/acctestswhenglu910/firewallRules/test"
	apiVersion := "2021-06-01"

	//commonClient.GET(context.Background(), url, apiVersion)
	bodyJson := `
{
    "properties": {
        "startIpAddress": "0.0.0.0",
        "endIpAddress": "0.0.0.1"
    }
}
`
	var body interface{}
	err = json.Unmarshal([]byte(bodyJson), &body)
	if err != nil {
		t.Errorf("%v", err)
	}
	result, response, err := commonClient.Put(context.Background(), url, apiVersion, body)
	result, response, err = commonClient.Get(context.Background(), url, apiVersion)
	result, response, err = commonClient.Delete(context.Background(), url, apiVersion)
	fmt.Printf("%v %v %v", result, response, err)
}

func Test1(t *testing.T) {
	json1 := `
    {
      "location": "west europe",
      "properties": {
        "computeType": "ComputeInstance",
        "disableLocalAuth": true,
        "properties": {
          "vmSize": "STANDARD_NC6"
        }
      }
    }
`
	json2 := `
{"id":"/subscriptions/67a9759d-d099-4aa8-8675-e6cfd669c3f4/resourceGroups/acctestRG-ml-henglu917/providers/Microsoft.MachineLearningServices/workspaces/acctest-MLWhenglu917/computes/testhenglu917","location":"west europe","name":"testhenglu917","properties":{"computeLocation":"westeurope","computeType":"ComputeInstance","createdOn":"2021-09-17T08:45:00.1841498+00:00","description":null,"disableLocalAuth":false,"isAttachedCompute":false,"modifiedOn":"2021-09-17T08:51:42.9369713+00:00","properties":{"applicationSharingPolicy":"Shared","applications":[{"displayName":"Jupyter","endpointUri":"https://testhenglu917.westeurope.instances.azureml.ms"},{"displayName":"Jupyter Lab","endpointUri":"https://testhenglu917.westeurope.instances.azureml.ms/lab"},{"displayName":"RStudio","endpointUri":"https://testhenglu917-8787.westeurope.instances.azureml.ms"}],"computeInstanceAuthorizationType":null,"connectivityEndpoints":{"privateIpAddress":"10.0.0.5","publicIpAddress":"20.103.73.12"},"createdBy":{"userId":"a4aa5b5e-8054-440c-89e7-cb31bfbc8be7","userOrgId":"72f988bf-86f1-41af-91ab-2d7cd011db47"},"dataDisks":null,"dataMounts":null,"errors":[],"lastOperation":{"operationName":"Create","operationStatus":"Succeeded","operationTime":"2021-09-17T08:45:06.526+00:00"},"personalComputeInstanceSettings":null,"schedules":{"computeStartStop":[]},"setupScripts":null,"sshSettings":{"adminPublicKey":null,"adminUserName":"azureuser","sshPort":4001,"sshPublicAccess":"Disabled"},"state":"Running","subnet":null,"updateStatus":null,"versions":{"runtime":"3.0.01706.0003"},"vmSize":"STANDARD_NC6"},"provisioningErrors":null,"provisioningState":"Succeeded","resourceId":null},"tags":{},"type":"Microsoft.MachineLearningServices/workspaces/computes"}
`
	var old, new interface{}
	json.Unmarshal([]byte(json1), &old)
	json.Unmarshal([]byte(json2), &new)
	res := getUpdatedJson(old, new)
	fmt.Printf("%v", res)
}

func getUpdatedJson(old interface{}, new interface{}) interface{} {
	switch old.(type) {
	case map[string]interface{}:
		switch new.(type) {
		case map[string]interface{}:
			oldMap := old.(map[string]interface{})
			newMap := new.(map[string]interface{})
			res := make(map[string]interface{})
			for key := range oldMap {
				if newMap[key] != nil {
					res[key] = getUpdatedJson(oldMap[key], newMap[key])
				}
			}
			return res
		default:
			return new
		}
	case []interface{}:
		switch new.(type) {
		case []interface{}:
			oldArr := old.([]interface{})
			newArr := new.([]interface{})
			if len(oldArr) != len(newArr) {
				return newArr
			}
			res := make([]interface{}, 0)
			for index := range oldArr {
				res = append(res, getUpdatedJson(oldArr[index], newArr[index]))
			}
			return res
		default:
			return new
		}
	default:
		return new
	}
}
