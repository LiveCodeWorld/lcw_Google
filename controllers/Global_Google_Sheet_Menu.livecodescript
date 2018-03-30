script "Global_Google_Sheet_Menu"
--> MetaData
-
license: GPLv3
name: Global_Google_Sheet_Menu
type: controller
version: 0.1


--> Global | Google | Sheet | Menu
-
on menu_FindSites dgView
   put "tigrutigru" into nameStem
   put "https://www.google.se/?gfe_rd=cr&ei=ihuFVb6rFaar8wfVj4GoBA" into someURL
   put merge("&gws_rd=ssl#q=%22Welcome+visitors%22+%22site+owned+by+[[nameStem]]%22") after someURL
   -- set the browser_URL of dgView to someURL
   put url someURL
end menu_FindSites

on menu_LaunchYoutubeConsole
   launch url "https://console.developers.google.com/home/dashboard?project=liveworld-tube"
end menu_LaunchYoutubeConsole

on menu_GoogleCustomSearch
   put lcw_Ask ("What do you want to search for", "FEAST") into googleQuery
   --
   put "AIzaSyBzXWSK8iB1I9Vl72OwMj5RjkVfyKW23Rg" into cseApiKey
   put merge ("https://www.googleapis.com/customsearch/v1?q=[[googleQuery]]&cx=004437460006508948617%3Axrqa9sithze&num=10&key=[[cseApiKey]]") into restURL
   --
   put url restURL into someJSON
   display_JSON someJSON
end menu_GoogleCustomSearch

on menu_ImageSearch
   -- https://commons.wikimedia.org/w/api.php?action=query&generator=images&prop=imageinfo&gimlimit=500&redirects=1&titles=Cat&iiprop=timestamp|user|userid|comment|canonicaltitle|url|size|dimensions|sha1|mime|thumbmime|mediatype|bitdepth
   -- /w/api.php?action=query&format=json&origin=*&titles=North%20Africa&generator=allimages
   put lcw_Ask ("What do you want to search for", "Cat") into someTitle
   put urlencode (someTitle) into encodedTitle
   -- replace "+" with "%20" in encodedTitle
   --
   put "https://commons.wikimedia.org" into restURL
   put "/w/api.php?action=query&generator=images&prop=imageinfo" after restURL
   put "&gimlimit=100"  after restURL
   put "&redirects=1"  after restURL
   
   -- put "/w/api.php?action=query&format=json&origin=*&generator=allimages" after restURL
   put "&titles=" & encodedTitle after restURL
   put "&iiprop=timestamp|user|userid|comment|canonicaltitle|url|size|dimensions|sha1|mime|thumbmime|mediatype|bitdepth" after restURL
   put "&format=json" after restURL
   
   put url restURL into someJSON
   display_JSON  someJSON
end menu_ImageSearch


--> Global | Google | Sheet | Menu | Props
-

--> Global | Google | Sheet | Menu | Disabled
-
