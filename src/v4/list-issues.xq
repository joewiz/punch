xquery version "1.0";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace style = "http://history.state.gov/ns/xquery/style" at "../modules/style.xqm";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $breadcrumbs := <a href="{concat($style:web-path-to-app, '/v4/list-issues.xq')}">List Issues</a>

let $title := for $breadcrumb in $breadcrumbs return $breadcrumb/text()

let $body := 
    <div>
        <h2>{$title}</h2>
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

let $content := style:layout($body)


return 
    style:assemble-page($title, $breadcrumbs, $content)