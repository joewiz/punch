xquery version "1.0";

(:~ Module: punch.xqm
 :
 :  This module contains Punch-specific functions
 :)

module namespace punch = "http://history.state.gov/ns/punch";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function punch:issue-title($node) {
    let $doc := 
        if ($node/tei:TEI) then
            $node
        else 
            $node/ancestor::tei:TEI
   return $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
};

declare function punch:title-issue-section($issue, $section) {
    let $doc := doc(concat('/db/apps/punch/data/', $issue))
    let $div := $doc/id($section)
    let $title := concat(punch:issue-title($doc), ', ', punch:derive-title($div))
    return 
        $title
};

declare function punch:get-pages-from-div($div) {
    let $firstpage := ($div/preceding::tei:pb)[last()]/@n/string()
    let $lastpage := if ($div//tei:pb) then ($div//tei:pb)[last()]/@n/string() else ()
    return
        if ($firstpage ne '' or $lastpage ne '') then 
            concat(' (', string-join(($firstpage, $lastpage), '-'), ')') 
        else ()
};

declare function punch:generate-toc-from-divs($node, $issue) {
    if ($node/tei:div) then
        <ol>{
            for $div in $node/tei:div
            return punch:toc-div($div, $issue)
        }</ol>
    else ()
};

declare function punch:derive-title($div) {
    let $title := 
        if ($div/tei:head) then 
            string-join(for $node in $div/tei:head/node() return data($node), ' ') 
        else if ($div//tei:head) then 
            string-join(for $node in $div//tei:head/node() return data($node), ' ') 
        else if (string-length(data($div)) gt 0) then 
            concat('[', $div/@type/string(), '] ', substring(data($div), 1, 50), '...') 
        else 
            concat('[', $div/@type/string, ']')
    return $title
};

declare function punch:toc-div($div, $issue) {
    let $section := $div/@xml:id/string()
    let $title := punch:derive-title($div)
    return
        <li><a href="view-section.xq?issue={$issue}&amp;section={$section}">{$title}</a> 
            { punch:get-pages-from-div($div) }
            { punch:generate-toc-from-divs($div, $issue) }
        </li>
};