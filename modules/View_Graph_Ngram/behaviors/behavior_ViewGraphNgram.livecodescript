script "behavior_ViewGraphNgram"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewGraphNgram
type: behavior
version: 0.1

getprop displayed_Data
   put the csvData of me into timeArray
   split timeArray using CR and comma
   return timeArray
end displayed_Data

setprop displayed_Data timeArray
   combine timeArray using CR and comma
   set the csvData of me to timeArray
end displayed_Data
