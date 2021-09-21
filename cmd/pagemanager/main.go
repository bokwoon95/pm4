package main

import (
	"fmt"
	"log"
	"os"

	"github.com/bokwoon95/pm4"
	"github.com/davecgh/go-spew/spew"
)

func main() {
	tmplfs := pm4.NewTemplateFS(os.DirFS("/Users/bokwoon/Documents/pm4/pm-templates"), os.DirFS("/Users/bokwoon/Documents/pm4/pm-assets"))
	tmplBundle, err := tmplfs.GetTemplateBundle("plainsimple/index.html")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf(".TemplateFiles: %v\n", tmplBundle.TemplateFiles)
	fmt.Printf(".DataFiles: %v\n", tmplBundle.DataFiles)
	fmt.Printf(".DataQueries: %v\n", tmplBundle.DataQueries)
	fmt.Printf(".DataFunctions: %v\n", tmplBundle.DataFunctions)
	fmt.Printf(".Data: %v\n", tmplBundle.Data)
	err = tmplBundle.Template.Execute(os.Stdout, tmplBundle.Data)
	if err != nil {
		spew.Dump(tmplBundle.Template)
		log.Fatal(err)
	}
}
