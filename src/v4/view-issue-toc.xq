xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare default element namespace "http://www.w3.org/1999/xhtml";

import module namespace style = "http://history.state.gov/ns/xquery/style" at "../modules/style.xqm";
import module namespace punch = "http://history.state.gov/ns/punch" at "../modules/punch.xqm";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $issue := request:get-parameter('issue', '')
let $section := request:get-parameter('section', '')
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc/tei:TEI/tei:text
let $title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
let $breadcrumbs := ( <a href="list-issues.xq">List Issues</a>, <a href="">{$title}</a> )
let $body := 
    <div>
        <h2>{$title}</h2>
        {punch:generate-toc-from-divs($text/tei:body, $issue)}
    </div>
    
let $content := style:layout($body)

return
    style:assemble-page($title, $breadcrumbs, style:layout($content))