xquery version "1.0";

(:~ Module: tei-to-html.xqm
 :
 :  This module uses XQuery 'typeswitch' expression to transform TEI into HTML.
 :  It performs essentially the same function as XSLT stylesheets, but uses
 :  XQuery to do so.  If your project is already largely XQuery-based, you will 
 :  find it very easy to change and maintain this code, since it is pure XQuery.
 :
 :  This design pattern uses one function per TEI element (see
 :  the tei-to-html:dispatch() function starting on ~ line 47).  So if you 
 :  want to adjust how the module handles TEI div elements, for example, go to 
 :  tei-to-html:div().  If you need the module to handle a new element, just add 
 :  a function.  The length of the module may be daunting, but it is quite clearly
 :  structured.  
 :
 :  To use this module from other XQuery files, include the module 
 :     import module namespace render = "http://history.state.gov/ns/tei-to-html" at "../modules/tei-to-html.xqm";
 :  and pass the TEI fragment to tei-to-html:render() as
 :     tei-to-html:render($teiFragment, $options)
 :  where $options contains parameters and other info you might want your 
 :  tei-to-html functions to make use of in a parameters element:
 :     <parameters xmlns="">
 :         <param name="relative-image-path" value="/rest/db/punch/data/images/"/>
 :     </parameters>
 :)

module namespace tei-to-html = "http://history.state.gov/ns/tei-to-html";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: A helper function in case no options are passed to the function :)
declare function tei-to-html:render($content as node()*) as element() {
    tei-to-html:render($content, ())
};

(: The main function for the tei-to-html module: Takes TEI content, turns it into HTML, and wraps the result in a div element :)
declare function tei-to-html:render($content as node()*, $options as element(parameters)*) as element() {
    <div class="document">
        { tei-to-html:dispatch($content, $options) }
    </div>
};

(: Typeswitch routine: Takes any node in a TEI content and either dispatches it to a dedicated 
 : function that handles that content (e.g. div), ignores it by passing it to the recurse() function
 : (e.g. text), or handles it directly (e.g. lb). :)
declare function tei-to-html:dispatch($node as node()*, $options) as item()* {
    typeswitch($node)
        case text() return $node
        case element(tei:TEI) return tei-to-html:recurse($node, $options)
        case element(tei:text) return tei-to-html:recurse($node, $options)
        case element(tei:front) return tei-to-html:recurse($node, $options)
        case element(tei:body) return tei-to-html:recurse($node, $options)
        case element(tei:back) return tei-to-html:recurse($node, $options)
        case element(tei:div) return tei-to-html:div($node, $options)
        case element(tei:head) return tei-to-html:head($node, $options)
        case element(tei:p) return tei-to-html:p($node, $options)
        case element(tei:hi) return tei-to-html:hi($node, $options)
        case element(tei:list) return tei-to-html:list($node, $options)
        case element(tei:item) return tei-to-html:item($node, $options)
        case element(tei:label) return tei-to-html:label($node, $options)
        case element(tei:ref) return tei-to-html:ref($node, $options)
        case element(tei:said) return tei-to-html:said($node, $options)
        case element(tei:lb) return <br/>
        case element(tei:figure) return tei-to-html:figure($node, $options)
        case element(tei:graphic) return tei-to-html:graphic($node, $options)
        case element(tei:table) return tei-to-html:table($node, $options)
        case element(tei:row) return tei-to-html:row($node, $options)
        case element(tei:cell) return tei-to-html:cell($node, $options)
        case element(tei:pb) return tei-to-html:pb($node, $options)
        case element(tei:lg) return tei-to-html:lg($node, $options)
        case element(tei:l) return tei-to-html:l($node, $options)
        case element(tei:name) return tei-to-html:name($node, $options)
        case element(tei:milestone) return tei-to-html:milestone($node, $options)
        case element(tei:quote) return tei-to-html:quote($node, $options)
        case element(tei:said) return tei-to-html:said($node, $options)
        default return tei-to-html:recurse($node, $options)
};

(: Recurses through the child nodes and sends them tei-to-html:dispatch() :)
declare function tei-to-html:recurse($node as node(), $options) as item()* {
    for $node in $node/node()
    return 
        tei-to-html:dispatch($node, $options)
};

declare function tei-to-html:div($node as element(tei:div), $options) {
    if ($node/@xml:id) then tei-to-html:xmlid($node, $options) else (),
    tei-to-html:recurse($node, $options)
};

declare function tei-to-html:head($node as element(tei:head), $options) as element() {
    (: div heads :)
    if ($node/parent::tei:div) then
        let $type := $node/parent::tei:div/@type
        let $div-level := count($node/ancestor::div)
        return
            element {concat('h', $div-level + 2)} {tei-to-html:recurse($node, $options)}
    (: figure heads :)
    else if ($node/parent::tei:figure) then
        if ($node/parent::tei:figure/parent::tei:p) then
            <strong>{tei-to-html:recurse($node, $options)}</strong>
        else (: if ($node/parent::tei:figure/parent::tei:div) then :)
            <p><strong>{tei-to-html:recurse($node, $options)}</strong></p>
    (: list heads :)
    else if ($node/parent::tei:list) then
        <li>{tei-to-html:recurse($node, $options)}</li>
    (: table heads :)
    else if ($node/parent::tei:table) then
        <p class="center">{tei-to-html:recurse($node, $options)}</p>
    (: other heads? :)
    else
        tei-to-html:recurse($node, $options)
};

declare function tei-to-html:p($node as element(tei:p), $options) as element() {
    let $rend := $node/@rend
    return 
        if ($rend = ('right', 'center') ) then
            <p>{ attribute class {data($rend)} }{ tei-to-html:recurse($node, $options) }</p>
        else <p>{tei-to-html:recurse($node, $options)}</p>
};

declare function tei-to-html:hi($node as element(tei:hi), $options) as element()* {
    let $rend := $node/@rend
    return
        if ($rend = 'it') then
            <em>{tei-to-html:recurse($node, $options)}</em>
        else if ($rend = 'sc') then
            <span style="font-variant: small-caps;">{tei-to-html:recurse($node, $options)}</span>
        else 
            <span class="hi">{tei-to-html:recurse($node, $options)}</span>
};

declare function tei-to-html:list($node as element(tei:list), $options) as element() {
    <ul>{tei-to-html:recurse($node, $options)}</ul>
};

declare function tei-to-html:item($node as element(tei:item), $options) as element()+ {
    if ($node/@xml:id) then tei-to-html:xmlid($node, $options) else (),
    <li>{tei-to-html:recurse($node, $options)}</li>
};

declare function tei-to-html:label($node as element(tei:label), $options) as element() {
    if ($node/parent::tei:list) then 
        (
        <dt>{$node/text()}</dt>,
        <dd>{$node/following-sibling::tei:item[1]}</dd>
        )
    else tei-to-html:recurse($node, $options)
};

declare function tei-to-html:xmlid($node as element(), $options) as element() {
    <a name="{$node/@xml:id}"/>
};

declare function tei-to-html:ref($node as element(tei:ref), $options) {
    let $target := $node/@target
    return
        element a { 
            attribute href { $target },
            attribute title { $target },
            tei-to-html:recurse($node, $options) 
            }
};

declare function tei-to-html:said($node as element(tei:said), $options) as element() {
    <p class="said">{tei-to-html:recurse($node, $options)}</p>
};

declare function tei-to-html:figure($node as element(tei:figure), $options) {
    <div class="figure">{tei-to-html:recurse($node, $options)}</div>
};

declare function tei-to-html:graphic($node as element(tei:graphic), $options) {
    let $url := $node/@url
    let $head := $node/following-sibling::tei:head
    let $width := if ($node/@width) then $node/@width else '800px'
    let $relative-image-path := $options/*:param[@name='relative-image-path']/@value
    return
        <img src="{if (starts-with($url, '/')) then $url else concat($relative-image-path, $url)}" alt="{normalize-space($head[1])}" width="{$width}"/>
};

declare function tei-to-html:table($node as element(tei:table), $options) as element() {
    <table>{tei-to-html:recurse($node, $options)}</table>
};

declare function tei-to-html:row($node as element(tei:row), $options) as element() {
    let $label := $node/@role[. = 'label']
    return
        <tr>{if ($label) then attribute class {'label'} else ()}{tei-to-html:recurse($node, $options)}</tr>
};

declare function tei-to-html:cell($node as element(tei:cell), $options) as element() {
    let $label := $node/@role[. = 'label']
    return
        <td>{if ($label) then attribute class {'label'} else ()}{tei-to-html:recurse($node, $options)}</td>
};

declare function tei-to-html:pb($node as element(tei:pb), $options) {
    if ($node/@xml:id) then tei-to-html:xmlid($node, $options) else (),
    if ($options/*:param[@name='show-page-breaks']/@value = 'true') then
        <span class="pagenumber">{
            concat('Page ', $node/@n/string())
        }</span>
    else ()
};

declare function tei-to-html:lg($node as element(tei:lg), $options) {
    <div class="lg">{tei-to-html:recurse($node, $options)}</div>
};

declare function tei-to-html:l($node as element(tei:l), $options) {
    let $rend := $node/@rend
    return
        if ($node/@rend eq 'i2') then 
            <div class="l" style="padding-left: 2em;">{tei-to-html:recurse($node, $options)}</div>
        else 
            <div class="l">{tei-to-html:recurse($node, $options)}</div>
};

declare function tei-to-html:name($node as element(tei:name), $options) {
    let $rend := $node/@rend
    return
        if ($rend eq 'sc') then 
            <span class="name" style="font-variant: small-caps;">{tei-to-html:recurse($node, $options)}</span>
        else 
            <span class="name">{tei-to-html:recurse($node, $options)}</span>
};

declare function tei-to-html:milestone($node as element(tei:milestone), $options) {
    if ($node/@unit eq 'rule') then
        if ($node/@rend eq 'stars') then 
            <div style="text-align: center">* * *</div>
        else if ($node/@rend eq 'hr') then
            <hr style="margin: 7px;"/>
        else
            <hr/>
    else 
        <hr/>
};

declare function tei-to-html:quote($node as element(tei:quote), $options) {
    <blockquote>{tei-to-html:recurse($node, $options)}</blockquote>
};

declare function tei-to-html:said($node as element(tei:said), $options) {
    <span class="said">{tei-to-html:recurse($node, $options)}</span>
};