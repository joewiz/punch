![Punch masthead](https://raw.githubusercontent.com/joewiz/punch/master/icon.png)

# Punch

A simple application written in XQuery for eXist demonstrating how to create a dynamic, searchable website for TEI text.

## Overview 

This application leads students through through four "versions" of a sample application, from a simple listing of 
documents through a number of common challenges involving putting complex XML documents such as TEI on the web. 
Techniques demonstated include using FLWOR expressions to traverse top-level TEI `div` elements and turn their 
contents into HTML, creating links from one view of data to the next, using typeswitch expressions and functions 
to recursively process a document's contents, displaying images referred to in the TEI text in the HTML view, 
using function modules to separate the main content of a page from its header, footer, and other common elements, 
and creating full text search indexes and a web interface to performing searches and viewing the results with keyword
highlighting.

## Installation

I assume you have already downloaded an installed the [latest release](https://github.com/eXist-db/exist/releases) of eXist. 
This app was tested with eXist version 2.2RC.

Download the [latest release](https://github.com/joewiz/punch/releases) of Punch as a .xar file, or clone the repository 
and build the package from source. 

Then install the .xar from the Package Manager pane of the eXist Dashboard app - typically at `http://localhost:8080/exist/apps/dashboard/index.html`.

Once the Punch app is installed, it will appear in the list of apps in the Dashboard. Access the app directly at `http://localhost:8080/exist/apps/punch/index.xq`.

## Background

I originally created this application to accompany the eXist workshops I gave at 
[TEI@Oxford 2010](http://tei.oucs.ox.ac.uk/Talks/2010-07-oxford/workshops.xml#div_exist) and 
[Digital.Humanities@Oxford Summer School 2011](http://digital.humanities.ox.ac.uk/dhoxss/2011/sessions.html#xmldb).  

These workshops at Oxford each came at the end of a week of intensive instruction in the theory and practice of TEI and 
other digital humanities technologies.  The TEI sessions all used the 19th century British satirical magazine 
[Punch](http://en.wikipedia.org/wiki/Punch_(magazine)) as the sample text, so I used some sample texts and their 
accompanying images as the basis for this application.

Since then the slides of my presentation and the files have been accessible at the Oxford sites linked above, 
but I am now re-releasing the application on GitHub for a few reasons:

1. eXist now has a fantastic facility for sharing and installing applications in single file packages known as ".xar files" 
or, more properly, [EXPath Packages](http://expath.org/spec/pkg). Getting the package installed in your own eXist 
system is as simple as downloading [a release](https://github.com/joewiz/punch/releases) or building the .xar from source, 
then installing it from the Package Manager pane of the eXist Dashboard app. This is much, much easier than the previous 
method of installing the app.

2. I kept hearing from the TEI community that this Punch app and the accompanying slides were uniquely useful to others 
getting started writing applications around eXist and TEI. 

3. eXist has made several other advancements that I could demonstrate by updating this application to incorporate them. 
These advances include the new convention of storing apps in the `/db/apps/` folder and accessing them at the 
`/apps` URL; the EXPath Package facility, with its single-file distribution, its automated installation with index 
configurations copied into the correct location via the `pre-install.xql` script; and the EXPath Package support in the 
fantastic eXide app for editing and testing XQuery apps in eXist.

One advancement in eXist I have not adapted this app to use is the [templating facility](http://exist-db.org/exist/apps/doc/templating.xml), 
which lets app authors separate their XQuery from their HTML. This is an ingenious system, but I feel there is some 
pedagogical benefit to first learning XQuery web development without the templating system. Perhaps a future version 
of this app will incorporate it as a fifth step.

## Acknowledgments

Thanks to James Cummings, the main organizer of the two workshops, for inviting me, and to the Office of the Historian for
allowing me to travel for this conference.
