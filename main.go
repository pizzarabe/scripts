package main

import (
"fmt"
"os"
"net/http"
"strings"
)

func errorcheck(err error) {
if err != nil {
        fmt.Println(err)
        os.Exit(1)
        }
}

func loghit(r *http.Request) {
fmt.Printf("%s %s %s%s from %s\n",r.Method, r.Proto, r.Host, r.URL.Path, r.RemoteAddr)
}

func main() {
mux := http.NewServeMux()
contentdirname := "./content"
contentdir,err := os.Open(contentdirname)
errorcheck(err)
defer contentdir.Close()
files := []os.FileInfo{}
files,err = contentdir.Readdir(0)
errorcheck(err)
for _,file := range files {
	if file.IsDir() == !true {
	fmt.Println(file.Name())
	openFile,err := os.Open(fmt.Sprintf("%s/%s", contentdirname,file.Name()))
	errorcheck(err)
	defer openFile.Close()
	bytes := make([]byte, file.Size())
	_,err = openFile.Read(bytes)
	errorcheck(err)
	content := string(bytes[:])
	mux.HandleFunc(fmt.Sprintf("/%s", file.Name()), func(w http.ResponseWriter, r *http.Request) {
	_,err := fmt.Fprint(w, content)
	errorcheck(err)
	loghit(r)
				})

	if strings.ToLower(file.Name()) == "index.html" {
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, "/index.html", 303)
	loghit(r)
				})
			}
		}
	}
http.ListenAndServe(":8080", mux)
}
