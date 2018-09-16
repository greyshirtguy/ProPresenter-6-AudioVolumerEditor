# Pro6AudioVolumerEditor

ProPresenter 6 allows you to add Audio cues to slides - but there is nowhere to set the volume of each cue.
This application lets you open a Pro6 document that has Audio (and Video) cues attached to slides and edit the volumes
of each audio (or video) cue on each slide while listening.  Only works on Mac.
(The windows version of Pro6 doesn't use any custom volumes for audio cues - it ignores them and plays full volume.)

How to use this application:
Close ProPresenter6.
Make a backup Your library :)
Back it up again :)
Open this app - Your library should be listed on the left side 
(Only works with default library in version 1 - Selecting library is on the TODO list)
Scroll through the library and select your document - it should appear in the slide viewer.
Any slide that has audio (or video) will have an symbol in the top left to indicate so.
Those slides will also have a volume slider showing the current volume of that media item for that slide.
Click a slide to preview the audio.  Slide the volume slider to adjust.
Once you are happy with changes (I guess all slides have a similar volume) - then click save button at bottom.

Disclaimer:
This is not supported by the makers or ProPresenter 6.  Use at your own risk. Make a backup copy of your library folder first!
It should hopefully be pretty safe to use.
The logic is pretty simple and should not result in any corruption.
It reads in the Pro6 file as a sinlge XML document object, update the volume attributes of AudioElements with new volumes
and re-saves the XML back to the document.


TODO: 
Update to allow editing volumes in Audio bin playlists.
