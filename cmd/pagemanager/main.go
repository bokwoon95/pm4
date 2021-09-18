package main

import (
	"fmt"
	"log"

	"github.com/bokwoon95/pm4"
)

func main() {
	pm4.New()
	s, err := pm4.RenderTemplate("plainsimple/index.html")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(s)
}
