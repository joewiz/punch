xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';
     
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Punch</title>
    </head>
    <body>
        <div>
            <h1>Punch: Browse by Issue</h1>
            <ol>
                {
                for $issue in collection('/db/apps/punch/data')/tei:TEI
                let $title := $issue/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
                let $file := util:document-name($issue)
                order by $title
                return 
                    <li><a href="{concat('view-issue-toc.xq?issue=', $file)}">{$title/text()}</a></li>
                }
            </ol>
        </div>
    </body>
</html>
