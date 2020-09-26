---
title: 🐬golang 使用 socks5 代理
date: '2019-05-21'
author: DG
slug: golang-use-socks5-proxy
tags:
  - 编程
  - 代码
categories: 
  - golang
---

```golang
package main

import (
   "fmt"
   "io/ioutil"
   "log"
   "net/http"
   "os"

   "golang.org/x/net/proxy"
)

func main() {
   // create a socks5 dialer
   dialer, err := proxy.SOCKS5("tcp", "127.0.0.1:1080", nil, proxy.Direct)
   if err != nil {
      _, _ = fmt.Fprintln(os.Stderr, "can't connect to the proxy:", err)
      os.Exit(1)
   }
   // setup a http client
   httpTransport := &http.Transport{}
   httpClient := &http.Client{Transport: httpTransport}
   // set our socks5 as the dialer
   httpTransport.Dial = dialer.Dial
   if resp, err := httpClient.Get("https://www.baidu.com"); err != nil {
      log.Fatalln(err)
   } else {
      defer resp.Body.Close()
      body, _ := ioutil.ReadAll(resp.Body)
      fmt.Printf("%s\n", body)
   }
}
```

但是 `transport` 的 `Dial` 属性已经被官方弃用，推荐代替的是 `DialContext` 属性。但是 `proxy` 包中的 `SOCKS5` 只能返回一个只包含 `Dial` 的 `Dialer`，不知到官方什么时候更新。

