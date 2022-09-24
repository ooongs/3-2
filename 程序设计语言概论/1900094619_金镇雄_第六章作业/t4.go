package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"sort"
	"unicode"
	"unicode/utf8" 
)

func main() {
	counts := make(map[rune]int)
	categories := make(map[string]int)
	var utflen [utf8.UTFMax + 1]int
	invalid := 0

	in := bufio.NewReader(os.Stdin)
	for {
		r, n, err := in.ReadRune()
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Fprintf(os.Stderr, "charcount: %v\n", err)
			os.Exit(1)
		}
		if r == unicode.ReplacementChar && n == 1 {
			invalid++
			continue
		}
		// Modify it to count letters, digits in their Unicode categories.
		if unicode.IsDigit(r) {
			categories["Digit"]++
		}
		if unicode.IsLetter(r) {
			categories["Letter"]++
		}
		counts[r]++
		utflen[n]++
	}
	// 4.1 Write a program charCount to compute counts of Unicode characters in input (Stdin). 
	fmt.Printf("rune\tcount\n")
	for c, n := range counts {
		fmt.Printf("%q\t%d\n", c, n)
	}
	fmt.Print("\nlen\tcount\n")
	for i, n := range utflen {
		if i > 0 {
			fmt.Printf("%d\t%d\n", i, n)
		}
	}
	if invalid > 0 {
		fmt.Printf("\n%d invalid UTF-8 characters\n", invalid)
	}
	// 4.1 Modify it to count letters, digits in their Unicode categories.
	fmt.Print("\ncategories\tcount\n")
	fmt.Printf("%s\t%d\n", "Digit", categories["Digit"])
	fmt.Printf("%s\t%d\n", "Letter", categories["Letter"])
}
