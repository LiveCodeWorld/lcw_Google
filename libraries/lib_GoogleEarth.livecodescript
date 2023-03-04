script "lib_GoogleEarth"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_GoogleEarth
type: library
version: 0.1

/*
In this library we look to script Google Earth Pro, and Google Earth Engine in order to create imagery we can use in the federation.
*/


--> Working on
-


--> Google | Earth
-
command display_EarthJson
   answer file "Select a zip file to process..."
   if it is empty then exit to top
   put it into archivePath
   --
   revZipOpenArchive archivePath, "read"
   put revZipEnumerateItems (archivePath) into espItem
   filter espItem with "*.esp"
   --
   revZipExtractItemToVariable archivePath, "ImagerySources.txt", imagerySources
   revZipExtractItemToVariable archivePath, espItem, espJson
   --
   revZipCloseArchive archivePath
   --
   put imagerySources
   display_Json espJson, "Google Earth Studio"
end display_EarthJson

command earth_Unzip
   answer file "Select a zip file to process..."
   if it is empty then exit to top
   put it into archivePath
   --
   set the itemdelimiter to slash
   put archivePath into footageFolder
   put "footage_" & the seconds & slash into item -1 of footageFolder
   folder_CreateNested footageFolder
   --
   revZipOpenArchive archivePath, "read"
   --
   put revZipEnumerateItems (archivePath) into zipItems
   filter zipItems with "footage/*.jpeg"
   --
   repeat for each line zipItem in zipItems
      set the cursor to busy
      put item -1 of zipItem into shortFile
      put footageFolder & shortFile into imageFile
      --
      -- revZipExtractItemToVariable archivePath, zipItem, someImage
      revZipExtractItemToFile archivePath, zipItem, imageFile
      --
   end repeat
   --
   revZipCloseArchive archivePath
   --
   put item -1 of archivePath into shortAchiveFile
   set the itemdelimiter to "."
   put item 1 of shortAchiveFile into shortName
   --
   ffmpeg_CreateStopFrameVideo footageFolder, shortName
   finder_RevealFileOrFolder exportPath
end earth_Unzip

command ffmpeg_CreateStopFrameVideo footageFolder, pShortName
   -- can be slow
   if there is not a folder footageFolder then return merge ("error, folder '[[footageFolder]]' does not exist")
   if pShortName is empty then put "output" into pShortName
   --
   put the defaultfolder into oFolder
   set the defaultfolder to footageFolder
   put merge ("ffmpeg -framerate 30 -pattern_type glob -i '*.jpeg' -c:v libx264 -pix_fmt yuv420p [[pShortName]].mp4") into someShell
   --
   put shell (someShell) into shellResult
   --
   set the defaultfolder to oFolder
   return shellResult
end ffmpeg_CreateStopFrameVideo
