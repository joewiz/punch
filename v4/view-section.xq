xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace tei-to-html = "http://history.state.gov/ns/tei-to-html" at "../modules/tei-to-html.xqm";
import module namespace style = "http://history.state.gov/ns/xquery/style" at "../modules/style.xqm";
import module namespace punch = "http://history.state.gov/ns/punch" at "../modules/punch.xqm";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $issue := request:get-parameter('issue', '')
let $section := request:get-parameter('section', '')
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc/id($section)
let $title := punch:issue-title($doc)
let $breadcrumbs := 
    (
    <a href="list-issues.xq">List Issues</a>, 
    <a href="view-issue-toc.xq?issue={$issue}">{$title}</a>,
    <a href="">{punch:derive-title($text)}</a>
    )

let $tei-to-html := tei-to-html:render($text, 
                    <parameters xmlns="">
                        <param name="relative-image-path" value="{concat($style:web-path-to-app, '/data/')}"/>
                    </parameters>)

let $body := 
    if (not($tei-to-html/h2)) then <div><h2>{punch:derive-title($text)}</h2>{$tei-to-html}</div>
    else $tei-to-html

let $content := style:layout($body)

return
    style:assemble-page($title, $breadcrumbs, $content)