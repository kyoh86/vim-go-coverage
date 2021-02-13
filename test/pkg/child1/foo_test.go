package child1_test

import (
	"testing"

	testtarget "github.com/kyoh86/testpkg/child1"
)

func Test(t *testing.T) {
	const want = 3
	got := testtarget.Add(1, 2)
	if want != got {
		t.Errorf("add mismatch: -want +got\n  -%d\n  +%d", want, got)
	}
}
