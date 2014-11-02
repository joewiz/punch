xquery version "1.0";

(: index.xq :)

(: This XQuery file provides links to the main pages for this tutorial. :)

(: Since we want our results to be sent to the browser as HTML (as opposed to XML or text), 
 : we need to use this declaration :)
declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

(: Here the main routine of our XQuery begins: an HTML root element and its content.  
 : It is perfectly valid to embed your HTML inside an XQuery, with no XQuery expressions 
 :)
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Digital.Humanities@Oxford: Punch eXist Tutorial Website</title>
    </head>
    <body>
        <div>
            <h1>Digital.Humanities@Oxford: Punch eXist Tutorial Website</h1>
            <p>Welcome to the Punch eXist Tutorial Website, developed for the Digital.Humanities@Oxford 
                Summer School in July 2011.</p>
            <p>The tutorial demonstrates the development of a website around the Punch 
                materials.  Each "version" of the site improves the presentation and 
                usefulness of the site:
                <ul>
                    <li><a href="v1/list-issues.xq">Punch v1</a>: We will list the issues 
                        of Punch and create a link out of each issue.  Click on the link 
                        to select an issue to view.  The TEI is transformed into HTML
                        using an imported XQuery module, "tei-to-html."  But since we transform 
                        an entire issue, the page is very long and slow to load.</li>
                    <li><a href="v2/list-issues.xq">Punch v2</a>: To overcome the problem
                        of slow loading and seeing too much on a page, we add a basic table of 
                        contents for each issue.  We add a link to each entry in the table 
                        of contents, so we can view just the section we're interested in.  
                        But the table of contents is very basic, only showing the top-level
                        divs.</li>
                    <li><a href="v3/list-issues.xq">Punch v3</a>: We improve on the table 
                        of contents, showing sub-entries.  We do this by moving our table of
                        contents code into an XQuery function, and calling it recursively
                        when there are sub-entries.</li>
                    <li><a href="v4/list-issues.xq">Punch v4</a>: We build on these small
                        steps and take a huge leap forward.  Most noticeably, we improve the 
                        visual appearance of the site, by adding CSS.  Under the hood, we 
                        have, centralizing all of our HTML into a template function, stored 
                        in a style module; this offloads much of the repetitive HTML code 
                        from each page, and allows us to add new pages quickly.  Also, we 
                        add a full text search page, and add the search box to the header 
                        of every page.  Because the search page needs to use much of the 
                        same code as the table of contents page, we store this code in a new 
                        "punch" module.</li>
                </ul>
            </p>
        </div>
    </body>
</html>