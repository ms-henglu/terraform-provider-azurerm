package common

import (
	"context"
	"github.com/Azure/go-autorest/autorest"
	"github.com/Azure/go-autorest/autorest/azure"
	"net/http"
)

const (
	// DefaultBaseURI is the default URI used for the service Synapse
	DefaultBaseURI = "https://management.azure.com"
)

// BaseClient is the base client for Synapse.
type BaseClient struct {
	autorest.Client
	BaseURI        string
	SubscriptionID string
}

// New creates an instance of the BaseClient client.
func New(subscriptionID string) BaseClient {
	return NewWithBaseURI(DefaultBaseURI, subscriptionID)
}

// NewWithBaseURI creates an instance of the BaseClient client using a custom endpoint.  Use this when interacting with
// an Azure cloud that uses a non-standard base URI (sovereign clouds, Azure stack).
func NewWithBaseURI(baseURI string, subscriptionID string) BaseClient {
	return BaseClient{
		Client:         autorest.NewClientWithUserAgent(""),
		BaseURI:        baseURI,
		SubscriptionID: subscriptionID,
	}
}

func NewCommonClientWithBaseURI(baseURI string, subscriptionID string) CommonClient {
	return CommonClient{NewWithBaseURI(baseURI, subscriptionID)}
}

type CommonClient struct {
	BaseClient
}

func (client CommonClient) Put(ctx context.Context, url string, apiVersion string, requestBody interface{}) (body interface{}, resp *http.Response, err error) {
	queryParameters := map[string]interface{}{
		"api-version": apiVersion,
	}

	preparer := autorest.CreatePreparer(
		autorest.AsContentType("application/json; charset=utf-8"),
		autorest.AsPut(),
		autorest.WithBaseURL(client.BaseURI),
		autorest.WithPathParameters(url, nil),
		autorest.WithJSON(requestBody),
		autorest.WithQueryParameters(queryParameters))
	req, err := preparer.Prepare((&http.Request{}).WithContext(ctx))
	if err != nil {
		err = autorest.NewErrorWithError(err, "common", "PUT", nil, "Failure preparing request")
		return
	}

	resp, err = client.Send(req, azure.DoRetryWithRegistration(client.Client))
	if err != nil {
		return
	}

	var azf azure.Future
	azf, err = azure.NewFutureFromResponse(resp)

	// it's a long running operation
	if err == nil {
		if err = azf.WaitForCompletionRef(ctx, client.Client); err != nil {
			return
		}
		resp = azf.Response()
	}

	var responseBody interface{}
	err = autorest.Respond(
		resp,
		azure.WithErrorUnlessStatusCode(http.StatusOK),
		autorest.ByUnmarshallingJSON(&responseBody),
		autorest.ByClosing())
	body = responseBody
	return
}

func (client CommonClient) Get(ctx context.Context, url string, apiVersion string) (body interface{}, resp *http.Response, err error) {
	queryParameters := map[string]interface{}{
		"api-version": apiVersion,
	}

	preparer := autorest.CreatePreparer(
		autorest.AsGet(),
		autorest.WithBaseURL(client.BaseURI),
		autorest.WithPathParameters(url, nil),
		autorest.WithQueryParameters(queryParameters))
	req, err := preparer.Prepare((&http.Request{}).WithContext(ctx))
	if err != nil {
		err = autorest.NewErrorWithError(err, "common", "GET", nil, "Failure preparing request")
		return
	}

	resp, err = client.Send(req, azure.DoRetryWithRegistration(client.Client))
	if err != nil {
		return
	}

	var responseBody interface{}
	err = autorest.Respond(
		resp,
		azure.WithErrorUnlessStatusCode(http.StatusOK),
		autorest.ByUnmarshallingJSON(&responseBody),
		autorest.ByClosing())
	body = responseBody
	return
}

func (client CommonClient) Delete(ctx context.Context, url string, apiVersion string) (body interface{}, resp *http.Response, err error) {
	queryParameters := map[string]interface{}{
		"api-version": apiVersion,
	}

	preparer := autorest.CreatePreparer(
		autorest.AsDelete(),
		autorest.WithBaseURL(client.BaseURI),
		autorest.WithPathParameters(url, nil),
		autorest.WithQueryParameters(queryParameters))
	req, err := preparer.Prepare((&http.Request{}).WithContext(ctx))
	if err != nil {
		err = autorest.NewErrorWithError(err, "common", "Delete", nil, "Failure preparing request")
		return
	}

	resp, err = client.Send(req, azure.DoRetryWithRegistration(client.Client))
	if err != nil {
		return
	}

	var azf azure.Future
	azf, err = azure.NewFutureFromResponse(resp)

	// it's a long running operation
	if err == nil {
		if err = azf.WaitForCompletionRef(ctx, client.Client); err != nil {
			return
		}
		resp = azf.Response()
	}

	var responseBody interface{}
	err = autorest.Respond(
		resp,
		azure.WithErrorUnlessStatusCode(http.StatusOK),
		autorest.ByUnmarshallingJSON(&responseBody),
		autorest.ByClosing())
	body = responseBody
	return
}
