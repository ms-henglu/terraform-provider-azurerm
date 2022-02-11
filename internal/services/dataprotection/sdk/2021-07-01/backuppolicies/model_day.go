package backuppolicies

type Day struct {
	Date   *int64 `json:"date,omitempty"`
	IsLast *bool  `json:"isLast,omitempty"`
}
