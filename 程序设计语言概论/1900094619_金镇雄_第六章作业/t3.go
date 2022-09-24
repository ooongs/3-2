
package main
import (
  "fmt"
  "unicode/utf8"
  // "bufio"
  // "os"
)
func main() {
  a := [...]int{0,1,2,3,4,5}
  reverse(a[:])
  fmt.Println(a)
//   str := "hello, 世界01234567890"
//   a := []byte(str)
//   reverse(a)
//   fmt.Println(a)
//   str2 := string(a)
//   fmt.Println(str2)
}

// 3.1: Write a function reverse which can reverse the elements of a [ ]int slice. 
// 		It may be applied to slices of any length.
func reverse(s []int){
  for i,j := 0,len(s)-1; i < j; i, j = i+1,j-1{
    s[i],s[j] = s[j],s[i]
  }
}

// 3.2: Rewrite reverse to use an array pointer instead of a slice. 
func reverse(arr *[10]int) {
	l := len(arr)
	for i := 0; i < l/2; i++ {
		j := l - i - 1
		arr[i], arr[j] = arr[j], arr[i]
	}
}

// 3.3： Modify reverse to reverse the characters of a [ ]byte slice 
// 		that represents a UTF-8-encoded string, in place. 
// 		Can you do it without allocating new memory? 

func reverse_byte(b []byte) {
	s := len(b)
	for i := 0; i < len(b)/2; i++ {
		b[i], b[s-i-1] = b[s-i-1], b[i]
	}
}

func reverse(b []byte) {
	for i := 0; i < len(b); {
		_, s := utf8.DecodeRune(b[i:])
		reverse_byte(b[i : i+s])
		i += s
	}
	reverse_byte(b)
}