---
title: Search
date: '2019-10-01'
slug: search
author: DG
---

<script
            src="https://code.jquery.com/jquery-3.4.1.js"
            integrity="sha256-WpOohJOqMqqyKL9FccASB9O0KwACQJpFTUBLTYOVvVU="
            crossorigin="anonymous"></script>
<script src="/js/parserxml.js"></script>
<style type="text/css">
		#site_search {
			margin: 60px 0 30px;
			text-align: left;
		}
		#local-search-input {
			width: 100%;
			height: 30px;
			outline: none;
			background-color: whitesmoke;
			border-right-color: whitesmoke;
			border-top: 0;
			border-left-color: gray;
			border-bottom: 0;
			box-shadow: none;
			padding: 0;

		}
		#local-search-result{
			padding: 0;
	        line-height: 1.25;
		}
		.search-keyword {
			color: orange;
		}
	</style>
<div id="site_search">
  <input type="text" id="local-search-input" name="q" results="0" placeholder="search my blog..." class="form-control"/>
  <div id="local-search-result"></div>
</div>
<script type="text/javascript">
     var path = "/index.xml";
     searchFunc(path, 'local-search-input', 'local-search-result');
</script>