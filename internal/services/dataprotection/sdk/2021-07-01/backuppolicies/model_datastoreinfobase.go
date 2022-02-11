package backuppolicies

type DataStoreInfoBase struct {
	DataStoreType DataStoreTypes `json:"dataStoreType"`
	ObjectType    string         `json:"objectType"`
}
