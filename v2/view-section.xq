xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace tei-to-html = "http://history.state.gov/ns/tei-to-html" at "../modules/tei-to-html.xqm";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $issue := request:get-parameter('issue', '')
let $section := request:get-parameter('section', '')
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc/id($section)
let $title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>{$title}</title>
    </head>
    <body>
        <div>
            <h1>{$title}</h1>
            {
            tei-to-html:render($text, 
                <parameters xmlns="">
                    <param name="relative-image-path" value="/apps/punch/data/"/>
                </parameters>)
            }
        </div>
    </body>
</html>
