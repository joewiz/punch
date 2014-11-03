xquery version "1.0";

(: view-whole-issue.xq :)

(: This simple XQuery file will take the "issue" parameter passed to it from view-issues.xq, 
 : and it will get the corresponding issue from the database.  Then, it will use the
 : tei-to-html module to turn the issue of Punch from TEI into HTML :)

declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: tei-to-html.xqm is an XQuery module stored in the modules collection. :)
import module namespace tei-to-html = "http://history.state.gov/ns/tei-to-html" at "../modules/tei-to-html.xqm";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';

(: This begins the main portion of this XQuery :)

(: request:get-parameter() is a function that gets "parameters" from the URL. 
 : For example, if a URL ends with ?q=hello, request:get-parameter('q', '') will return 'hello'.
 : The 2nd argument lets us specify a default value, or we can use '' to leave the default blank. :)
let $issue := request:get-parameter('issue', '')
(: We take $issue, e.g. 1914-07-01.xml, and can reconstruct the path to this document in the 
 : database by concatenating the base path to all Punch data with the $issue parameter. :)
let $doc := doc(concat('/db/apps/punch/data/', $issue))
let $text := $doc//tei:text
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
            (: The tei-to-html:render() function takes 2 arguments: 
             : 1. The TEI we want to display
             : 2. An optional set of parameters.  In this case, we provide the 
             :    "relative-image-path" for all TEI graphic elements; and we use
             :    "show-page-breaks" to specify that TEI pb elements should be shown.
             :)
            tei-to-html:render($text, 
                <parameters xmlns="">
                    <param name="relative-image-path" value="/exist/rest/db/apps/punch/data/"/>
                    <param name="show-page-breaks" value="true"/>
                </parameters>)
            }
        </div>
    </body>
</html>