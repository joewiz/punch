xquery version "1.0";

(: list-issues.xq :)

(: This simple XQuery file will list all of the issues of Punch, 
 : with a link to another XQuery which will display the entire issue. :)

(: Since we are querying TEI documents below, we have to declare the 
 : TEI namespace up here :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: Since we want our results to be sent to the browser as HTML (as opposed to XML or text), 
 : we need to use this declaration :)
declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

(: Here the main routine of our XQuery begins: an HTML root element, with some 
 : XQuery embedded in curly braces :)
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Punch</title>
    </head>
    <body>
        <div>
            <h1>Punch: Browse by Issue</h1>
            <ol>
                {
                (: For each TEI file in /db/apps/punch/data, we will get the issue's title and 
                 : filename, and we will use this to construct a link to view-whole-issue.xq :)
                for $issue in collection('/db/apps/punch/data')/tei:TEI
                let $title := $issue/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
                let $filename := util:document-name($issue)
                order by $title
                return 
                    <li><a href="{concat('view-whole-issue.xq?issue=', $filename)}">{$title/text()}</a></li>
                }
            </ol>
        </div>
    </body>
</html>
