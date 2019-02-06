script "lib_GoogleSitemap"
--> MetaData
-
license: GPLv3
name: lib_GoogleSitemap
type: library
version: 0.1

/*
This is the beginning of a library that can create and process Google sitemaps.
*/


--> Variables
-
constant cXMLNS = "http://www.sitemaps.org/schemas/sitemap/0.9"
constant cXMLNS_Content = "http://www.google.com/schemas/sitemap-content/1.0"
constant cXMLNS_Image ="http://www.google.com/schemas/sitemap-image/1.1"
constant cHapRoot = "http://himalayanacademy.com"
constant cHapDevRoot = "http://dev.himalayanacademy.com"


--> Sitemap | Index
-
function google_FetchSitemapArray someURL
   put url someURL into sitemapXML
   if sitemapXML is empty then return empty
   
   put xml_ToArray (sitemapXML) into sitemapArray
   return sitemapArray
end google_FetchSitemapArray

function sitemap_ListIndexURLs
   -- put "taka-sitemap.xml,book-sitemap.xml,video-sitemap.xml,audio-sitemap.xml,art-sitemap.xml,photos-sitemap.xml" into shortFiles
   put sitemap_ListHapRefinementNames() into refinementNames
   put ",html" after refinementNames
   put "http://himalayanacademy.com/blog/taka/sitemap.xml.gz" & CR after siteMapUrls
   repeat for each item refinementName in refinementNames
      put sitemap_ConstructShortFileName (refinementName) into shortSitemapFile
      put "http://himalayanacademy.com/" & shortSitemapFile & CR after siteMapUrls
   end repeat
   delete char -1 of siteMapUrls
   return siteMapUrls
end sitemap_ListIndexURLs

function sitemap_ConstructShortFileName refinementName
   put tolower (refinementName) & "-sitemap.xml" into shortSitemapFile   
   return shortSitemapFile
end sitemap_ConstructShortFileName

function sitemap_ConstructIndexXml siteMapUrls, pMakePretty
   put pMakePretty is not false into pIndent
   put date_ConstructWc3Datetime (the seconds) into dateNow
   repeat for each line someUrl in siteMapUrls
      put empty into someXML
      put xml_Enclose (someUrl, "loc", pIndent) after someXML
      put CR after someXML
      put xml_Enclose (dateNow, "lastmod", false) after someXML
      put CR after someXML
      put xml_Enclose (someXML, "sitemap", pIndent) into siteXML
      put siteXML & CR after sitesXML
   end repeat
   put xml_Enclose (sitesXML, "sitemapindex", pIndent, "xmlns", cXMLNS) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_ConstructIndexXml


--> Sitemap | Build
-
function sitemap_BuildImageSiteMap fileIDs, pPageType, pPriority
   -- was "sitemap_Construct"
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line fileID in fileIDs
      put sitemap_ConstructHapMediaUrl (fileID) into someUrl
      put xml_Enclose (someUrl, "loc", false) & CR into urlXML
      put xml_Enclose (dateNow, "lastmod", false) & CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      _addImageXML urlXML, pImageUrl
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS, "xmlns:content", cXMLNS_Content, "xmlns:image", cXMLNS_Image) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_BuildImageSiteMap

function sitemap_Build fileIDs, pPageType, pPriority
   -- was "sitemap_Construct"
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line fileID in fileIDs
      put sitemap_ConstructHapMediaUrl (fileID) into someUrl
      put xml_Enclose (someUrl, "loc", false) & CR into urlXML
      put xml_Enclose (dateNow, "lastmod", false) & CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS, "xmlns:content", cXMLNS_Content) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_Build

function sitemap_BuildFromUrls someUrls, pPageType, pPriority
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line someUrl in someUrls
      put xml_Enclose (someUrl, "loc", false) into urlXML
      put CR after urlXML
      
      put xml_Enclose (dateNow, "lastmod", false) after urlXML
      put CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_BuildFromUrls


--> Sitemap | List | Files
-
function sitemap_ListFileIDs refinementName
   put sitemap_HapRefinementToMediaTypes (refinementName) into mTypeList
   put sitemap_FileIDsFromMediaType (mTypeList) into fileIDs
   return fileIDs
end sitemap_ListFileIDs

function sitemap_FileIDsFromMediaType mTypeList
   rigDB_ItemByMediaType mTypeList
   rigDbSelect "file_id"
   put rigDbGet() into tQuery
   
   put rigDB_ExtractFirstThing (tQuery) into fileIDs
   return fileIDs
end sitemap_FileIDsFromMediaType


--> HAP | Refinements
-
function sitemap_HapRefinementToMediaTypes refinementName
   switch refinementName
      case "Image"
         put "art/photography,art/painting,art/drawing,art/vector" into mTypeList
      case "Photo"
         return "art/photography,slideshow/external,slideshow/galleria" into mTypeList
      case "Art"
         return "art/drawing,art/painting,art/vector" into mTypeList
      case "ArtPhoto"
         return "art/photography" into mTypeList
      case "Galleria"
         return "slideshow/galleria" into mTypeList
      case "Slideshow"
         return "slideshow/external,slideshow/galleria" into mTypeList
      case "Book"
         return "text/book,text/booklet,text/review" into mTypeList
      case "Audio"
         return "audio/inspiredtalk,audio/shum,audio/chant,audio/song" into mTypeList
      case "Video"
         return "video/building,video/news,video/pubdesk,video/ritual,video/talk,video/teaching,video/travel" into mTypeList
      default
         return empty
   end switch
end sitemap_HapRefinementToMediaTypes

function sitemap_ListHapRefinementNames
   return "Art,ArtPhoto,Audio,Book,Galleria,Image,Photo,Slideshow,Video"
end sitemap_ListHapRefinementNames


--> Sitemap | Encoding
-
command sitemap_EntityEscape @someURL
   -- see http://www.sitemaps.org/protocol.html#escaping
   
   text_Utf8Encode someURL
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someURL
      put urlencode (item itemNum of someURL) into item itemNum of someURL
   end repeat
   -- maybe some others need escaping, maybe none of these are actually needed
   replace "%3A" with ":" in someURL
   replace "%26" with "&" in someURL
   replace "%3D" with "=" in someURL
   xml_Escape someURL
end sitemap_EntityEscape


--> Private | Sitemap
-
private command _addImageXML @urlXML, pImageUrl
   if pImageUrl is not empty then
      put xml_Enclose (pImageUrl, "image:loc", false) & CR into imageLocTag
      put xml_Enclose (imageLocTag, "image:image", true) into imageXML
      put imageXML & CR after urlXML
   end if
end _addImageXML

private command _addPageMapXML @urlXML, pageMapXML
   if pageMapXML is not empty then
      put pageMapXML after urlXML
      put CR after urlXML
   end if
end _addPageMapXML

private command _addPriorityXML @urlXML, pPriority
   if pPriority is a number then
      put xml_Enclose (pPriority, "priority", false) after urlXML
      put CR after urlXML
   end if
end _addPriorityXML

private command _setPageMapXML @pageMapXML, pPageType
   if pPageType is empty then
      put empty into pageMapXML
   else
      put "http://www.google.com/schemas/sitemap-pagemap/1.0" into pagemapNameSpace
      put xml_Enclose (pageType, "Attribute", false, "name", "pagetype") into attributeXML
      put xml_Enclose (attributeXML, "DataObject", true, "type", "document") into dataObjectXML
      put xml_Enclose (dataObjectXML, "PageMap", true, "xmlns", pagemapNameSpace) into pageMapXML
   end if
end _setPageMapXML
