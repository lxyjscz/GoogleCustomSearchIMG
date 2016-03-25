# GoogleCustomSearchIMG

As the old google image search api is no longer be available, google custom search api with image search is used in this project instead.
There are only 100 search limits every day. If exceeds the limits, replace the google custom search api key and google search engine id in the request url part
The key is located in GoogleImageSeacher.swift -> URLString -> "&key={api key}&cx={search engine id}

The additional feature included is: 
Incoporate paging: Each page only contains 10 items. For each keywords, 3 pages = 30 images are loaded from google search api.
Automatic refreshing: When user is typing the keywords, the search result is updated to the view continuously.

