package dataprotection

import (
	"fmt"
	"os"
	"testing"
)

// Standard numbers map
var numbers map[string]int = map[string]int{"zero": 0, "three": 3}

// TestMain will exec each test, one by one
func TestMain(m *testing.M) {
	// exec setUp function
	setUp("one", 1)
	// exec test and this returns an exit code to pass to os
	retCode := m.Run()

	// exec tearDown function
	tearDown("one")
	// If exit code is distinct of zero,
	// the test will be failed (red)
	os.Exit(retCode)
}

// setUp function, add a number to numbers slice
func setUp(key string, value int) {
	fmt.Printf("setup")
	numbers[key] = value
}

// tearDown function, delete a number to numbers slice
func tearDown(key string) {
	fmt.Printf("teardown")
	delete(numbers, key)
}

// First test
func Test1(t *testing.T) {
	fmt.Printf("test1")
}

// Second test
func Test2(t *testing.T) {
	fmt.Printf("test2")
}