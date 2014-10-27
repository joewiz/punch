xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $issue := request:get-parameter('issue', '')
let $section := request:get-parameter('section', '')
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc/tei:TEI/tei:text/tei:body
let $title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>{$title}</title>
    </head>
    <body>
        <div>
            <h1>{$title}</h1>
            <ol>{
                for $div in $text//tei:div
                let $title := 
                    if ($div/tei:head) then 
                        data($div/tei:head)
                    else 
                        '(No title)'
                let $section := $div/@xml:id/string()
                return
                    <li>
                        <a href="view-section.xq?issue={$issue}&amp;section={$section}">{$title}</a>
                    </li>
            }</ol>
        </div>
    </body>
</html>