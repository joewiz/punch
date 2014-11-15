xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace tei-to-html = "http://history.state.gov/ns/tei-to-html" at "../modules/tei-to-html.xqm";
import module namespace style = "http://history.state.gov/ns/xquery/style" at "../modules/style.xqm";
import module namespace punch = "http://history.state.gov/ns/punch" at "../modules/punch.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

let $title := 'Search'
let $breadcrumbs := <a href="">Search</a>

let $query := request:get-parameter('q', '')
let $hits := collection('/db/apps/punch/data')//tei:div[ft:query(., $query)]
let $ordered-hits :=
    for $hit in $hits
    order by ft:score($hit) descending
    return $hit
let $hit-count := count($hits)

let $body :=
    <div>
        <h2>{$hit-count} results for "{$query}"</h2>
        <form action="search.xq" method="get">
            <p>Search: <input type="text" name="q" size="15" value="{$query}"/>
                <input class="gobox" type="submit" value="GO" />
            </p>
        </form>

        <ol>
        {
        for $hit in $ordered-hits
        let $snippet := kwic:summarize($hit, <config xmlns="" width="60"/>)
        let $issue := util:document-name($hit)
        let $section := $hit/@xml:id/string()
        let $title := punch:title-issue-section($issue, $section)
        return
            <li>
                <a href="view-section.xq?issue={$issue}&amp;section={$section}">{$title}</a>
                <blockquote>{$snippet}</blockquote>
            </li>
        }
        </ol>
    </div>
    
let $content := style:layout($body)

return
    style:assemble-page($title, $breadcrumbs, $content)
