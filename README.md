# MCL Proxy Safari App Extension
This is a Safari App Extension that allows MCL users to access academic journals through the institution's EZProxy service.
Tagged release versions will be posted to the Apple App Store, or you can build and install yourself from latest source. 

## Installing

1. Build from source and install in Applications (or download the app from the App Store.)
2. Open Safari, click on Safari in the menu bar, then Preferences.
3. Go to Extensions, and enable "MCL Proxy."
4. Then, you can use the padlock menu bar item to open the full versions of papers. You will be asked to
authenticate only once per browsing session. 

## Good (positive) test cases
1. https://www.nejm.com (no path)
2. https://www.healio.com/psychiatry/journals/psycann/2002-9-32-9/%7Bb9ab8f2c-53ce-4f76-b88e-2d5a70822f69%7D/the-phq-9-a-new-depression-diagnostic-and-severity-measure (percent escapes)
3. https://academic.oup.com/neurosurgery/article/87/3/602/5838842#207688542  (fragement intentionally discarded to discard paywall specific fragements)
