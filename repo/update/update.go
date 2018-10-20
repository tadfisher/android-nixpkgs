/* Adapted from https://raw.githubusercontent.com/eagletmt/android-repository-history/master/update.go */

/*
MIT License

Copyright (c) 2017 Kohei Suzuki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package main

import (
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"sync"
)

type SiteList2 struct {
	XMLName xml.Name `xml:"sdk-addons-list"`
	Sites   []Site2  `xml:"addon-site"`
}

type Site2 struct {
	XMLName xml.Name `xml:"addon-site"`
	Url     string   `xml:"url"`
}

type SiteList3 struct {
	XMLName xml.Name `xml:"site-list"`
	Sites   []Site3  `xml:"site"`
}

type Site3 struct {
	XMLName xml.Name `xml:"site"`
	Url     string   `xml:"url"`
}

func main() {
	baseUrl := "https://dl.google.com/android/repository"

	if err := os.RemoveAll("repository"); err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	wg.Add(4)
	go func() {
		updateAddons2(baseUrl)
		wg.Done()
	}()
	go func() {
		updateAddons3(baseUrl)
		wg.Done()
	}()
	go func() {
		updateRepository(baseUrl)
		wg.Done()
	}()
	go func() {
		updateRepository2(baseUrl)
		wg.Done()
	}()
	wg.Wait()
}

func updateAddons2(baseUrl string) {
	filepath, err := save(baseUrl, "addons_list-2.xml")
	if err != nil {
		log.Fatal(err)
	}

	file, err := os.Open(filepath)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	siteList := SiteList2{}
	if err := xml.NewDecoder(file).Decode(&siteList); err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	wg.Add(len(siteList.Sites))
	for _, site := range siteList.Sites {
		go func(site Site2) {
			_, err := save(baseUrl, site.Url)
			if err != nil {
				log.Fatal(err)
			}
			wg.Done()
		}(site)
	}
	wg.Wait()
}

func updateAddons3(baseUrl string) {
	filepath, err := save(baseUrl, "addons_list-3.xml")
	if err != nil {
		log.Fatal(err)
	}

	file, err := os.Open(filepath)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	siteList := SiteList3{}
	if err := xml.NewDecoder(file).Decode(&siteList); err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	wg.Add(len(siteList.Sites))
	for _, site := range siteList.Sites {
		go func(site Site3) {
			_, err := save(baseUrl, site.Url)
			if err != nil {
				log.Fatal(err)
			}
			wg.Done()
		}(site)
	}
	wg.Wait()
}

func updateRepository(baseUrl string) {
	var wg sync.WaitGroup
	versions := []uint{11, 12}
	wg.Add(len(versions))
	for _, version := range versions {
		go func(version uint) {
			filename := fmt.Sprintf("repository-%d.xml", version)
			if _, err := save(baseUrl, filename); err != nil {
				log.Fatal(err)
			}
			wg.Done()
		}(version)
	}
	wg.Wait()
}

func updateRepository2(baseUrl string) {
	var wg sync.WaitGroup
	versions := []uint{1}
	wg.Add(len(versions))
	for _, version := range versions {
		go func(version uint) {
			filename := fmt.Sprintf("repository2-%d.xml", version)
			if _, err := save(baseUrl, filename); err != nil {
				log.Fatal(err)
			}
			wg.Done()
		}(version)
	}
	wg.Wait()
}

func save(baseUrl string, filename string) (string, error) {
	url := fmt.Sprintf("%s/%s", baseUrl, filename)
	log.Printf("Downloading %s\n", url)
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	if resp.StatusCode != 200 {
		log.Fatalf("Unable to get %s: status=%d", url, resp.StatusCode)
	}
	filepath := fmt.Sprintf("repository/%s", filename)
	if err := os.MkdirAll(path.Dir(filepath), os.ModeDir|0755); err != nil {
		return "", err
	}
	file, err := os.Create(filepath)
	if err != nil {
		return "", err
	}
	io.Copy(file, resp.Body)
	file.Close()
	resp.Body.Close()
	return filepath, nil
}
