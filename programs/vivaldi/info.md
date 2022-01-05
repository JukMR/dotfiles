**NOTE:** this method only works if `Open Settings in a Tab` is activated.

This guide was taken from:
https://forum.vivaldi.net/topic/35443/backup-search-engines



To install this paste searchEngineBackup.js in vivaldi folder (check on vivaldi help or try this path:

/opt/vivaldi/resources/vivaldi

Then in the `<body>` html element on `browser.html` add:

```js

<script src="searchEngineBackup.js"></script>

```
Then reload vivaldi and the buttons should appear on search engines option.
