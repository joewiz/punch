xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

declare function local:get-pages-from-div($div) {
    let $firstpage := ($div/preceding::tei:pb)[last()]/@n/string()
    let $lastpage := if ($div//tei:pb) then ($div//tei:pb)[last()]/@n/string() else ()
    return
        if ($firstpage ne '' or $lastpage ne '') then 
            concat(' (', string-join(($firstpage, $lastpage), '-'), ')') 
        else ()
};

declare function local:generate-toc-from-divs($node, $issue) {
    if ($node/tei:div) then
        <ol>{
            for $div in $node/tei:div
            return local:toc-div($div, $issue)
        }</ol>
    else ()
};

declare function local:toc-div($div, $issue) {
    let $head := 
        if ($div/tei:head) then 
            string-join(for $node in $div/tei:head/node() return data($node), ' ') 
        else if ($div//tei:head) then 
            string-join(for $node in $div//tei:head/node() return data($node), ' ') 
        else if (string-length(data($div)) gt 0) then 
            concat('[', $div/@type/string(), '] ', substring(data($div), 1, 50), '...') 
        else 
            concat('[', $div/@type/string, ']')
    let $section := $div/@xml:id/string()
    return
        <li><a href="view-section.xq?issue={$issue}&amp;section={$section}">{$head}</a> 
            { local:get-pages-from-div($div) }
            { local:generate-toc-from-divs($div, $issue) }
        </li>
};

let $issue := request:get-parameter('issue', '')
let $section := request:get-parameter('section', '')
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc/tei:TEI/tei:text
let $title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>{$title}</title>
    </head>
    <body>
        <div>
            <h1>{$title}</h1>
            {local:generate-toc-from-divs($text/tei:body, $issue)}
        </div>
    </body>
</html>